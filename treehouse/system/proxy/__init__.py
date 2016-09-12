# -*- coding: utf-8 -*-
'''
    Overlord proxy logic
'''

# This file is part of overlord.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import logging
import zmq
from zmq.eventloop.zmqstream import ZMQStream
from zmq.eventloop.ioloop import IOLoop, PeriodicCallback


HB_INTERVAL = 1000  #: in milliseconds
HB_LIVENESS = 5    #: HBs to miss before connection counts as dead


def split_address(message):
    '''
        Function to split return Id and message received by ROUTER socket.

        Returns 2-tuple with return Id and remaining message parts.
        Empty frames after the Id are stripped.
    '''
    ret_ids = []
    for i, p in enumerate(message):
        if p:
            ret_ids.append(p)
        else:
            break
    return (ret_ids, message[i + 1:])


class OverlordProxy(object):
    '''
        The Overlord proxy class.

        The proxy routes messages from clients to appropriate workers based on the
        requested service.

        This base class defines the overall functionality and the API. Subclasses are
        ment to implement additional features (like logging).

        The proxy uses ØMQ ROUTER sockets to deal witch clients and workers. These sockets
        are wrapped in pyzmq streams to fit well into IOLoop.

        .. note::

          The workers will *always* be served by the 'main_ep' endpoint.

          In a two-endpoint setup clients will be handled via the 'opt_ep'
          endpoint.

        :param context:         the context to use for socket creation.
        :type context:          zmq.Context
        :param main_ep:         the primary endpoint for workers and clients.
        :type main_ep:          str
        :param opt_ep:          is an optional 2nd endpoint.
        :type opt_ep:           str
        :param service_q:       the class to be used for the service worker-queue.
        :type service_q:        class
    '''

    CLIENT_PROTO = b'OPC01'  #: Client protocol identifier
    WORKER_PROTO = b'OPW01'  #: Worker protocol identifier


    def __init__(self, context, main_ep, opt_ep=None, service_q=None):
        '''
            Init OverlordProxy instance.
        '''
        if service_q is None:
            self.service_q = ServiceQueue
        else:
            self.service_q = service_q
        socket = context.socket(zmq.ROUTER)
        socket.bind(main_ep)
        self.main_stream = ZMQStream(socket)
        self.main_stream.on_recv(self.on_message)
        if opt_ep:
            socket = context.socket(zmq.ROUTER)
            socket.bind(opt_ep)
            self.client_stream = ZMQStream(socket)
            self.client_stream.on_recv(self.on_message)
        else:
            self.client_stream = self.main_stream
        self._workers = {}
        # services contain the service queue and the request queue
        self._services = {}
        self._worker_cmds = { b'\x01': self.on_ready,
                              b'\x03': self.on_reply,
                              b'\x04': self.on_heartbeat,
                              b'\x05': self.on_disconnect,
                              }
        self.hb_check_timer = PeriodicCallback(self.on_timer, HB_INTERVAL)
        self.hb_check_timer.start()
        return

    def register_worker(self, wid, service):
        '''
            Register the worker id and add it to the given service.

            Does nothing if worker is already known.

            :param wid:         the worker id.
            :type wid:          str
            :param service:     the service name.
            :type service:      str

            :rtype:             None
        '''
        if wid in self._workers:
            return
        self._workers[wid] = WorkerRep(self.WORKER_PROTO, wid, service, self.main_stream)
        if service in self._services:
            wq, wr = self._services[service]
            wq.put(wid)
        else:
            q = self.service_q()
            q.put(wid)
            self._services[service] = (q, [])
        return

    def unregister_worker(self, wid):
        '''
            Unregister the worker with the given id.

            If the worker id is not registered, nothing happens.

            Will stop all timers for the worker.

            :param wid:         the worker id.
            :type wid:          str

            :rtype:             None
        '''
        try:
            wrep = self._workers[wid]
        except KeyError:
            # not registered, ignore
            return
        wrep.shutdown()
        service = wrep.service
        if service in self._services:
            wq, wr = self._services[service]
            wq.remove(wid)
        del self._workers[wid]
        return

    def disconnect(self, wid):
        '''
            Send disconnect command and unregister worker.

            If the worker id is not registered, nothing happens.

            :param wid:         the worker id.
            :type wid:          str

            :rtype:             None
        '''
        try:
            wrep = self._workers[wid]
        except KeyError:
            # not registered, ignore
            return
        to_send = [ wid, self.WORKER_PROTO, b'\x05' ]
        self.main_stream.send_multipart(to_send)
        self.unregister_worker(wid)
        return

    def client_response(self, rp, service, message):
        '''
            Package and send reply to client.

            :param rp:          return address stack
            :type rp:           list of str
            :param service:     name of service
            :type service:      str
            :param message:     message parts
            :type message:      list of str

            :rtype:             None
        '''
        to_send = rp[:]
        to_send.extend([b'', self.CLIENT_PROTO, service])
        to_send.extend(message)
        self.client_stream.send_multipart(to_send)
        return

    def shutdown(self):
        '''
            Shutdown broker.

            Will unregister all workers, stop all timers and ignore all further
            messages.

            .. warning:: The instance MUST not be used after :func:'shutdown' has been called.

            :rtype:             None
        '''
        if self.client_stream == self.main_stream:
            self.client_stream = None
        self.main_stream.on_recv(None)
        self.main_stream.socket.setsockopt(zmq.LINGER, 0)
        self.main_stream.socket.close()
        self.main_stream.close()
        self.main_stream = None
        if self.client_stream:
            self.client_stream.on_recv(None)
            self.client_stream.socket.setsockopt(zmq.LINGER, 0)
            self.client_stream.socket.close()
            self.client_stream.close()
            self.client_stream = None
        self._workers = {}
        self._services = {}
        return

    def on_timer(self):
        '''
            Method called on timer expiry.

            Checks which workers are dead and unregisters them.

            :rtype:             None
        '''
        for wrep in self._workers.values():
            if not wrep.is_alive():
                self.unregister_worker(wrep.id)
        return

    def on_ready(self, rp, message):
        '''
            Process worker READY command.

            Registers the worker for a service.

            :param rp:          return address stack
            :type rp:           list of str
            :param message:     message parts
            :type message:      list of str

            :rtype:             None
        '''
        ret_id = rp[0]
        self.register_worker(ret_id, message[0])
        return

    def on_reply(self, rp, message):
        '''
            Process worker REPLY command.

            Route the 'message' to the client given by the address(es) in front of 'message'.

            :param rp:          return address stack
            :type rp:           list of str
            :param message:     message parts
            :type message:      list of str

            :rtype:             None
        '''
        ret_id = rp[0]
        wrep = self._workers.get(ret_id)
        if not wrep:
            # worker not found, ignore message
            return
        service = wrep.service
        # make worker available again
        try:
            wq, wr = self._services[service]
            cp, message = split_address(message)
            self.client_response(cp, service, message)
            wq.put(wrep.id)
            if wr:
                proto, rp, message = wr.pop(0)
                self.on_client(proto, rp, message)
        except KeyError:
            # unknown service
            self.disconnect(ret_id)
        return

    def on_heartbeat(self, rp, message):
        '''
            Process worker HEARTBEAT command.

            :param rp:  return address stack
            :type rp:   list of str
            :param message: message parts
            :type message:  list of str

            :rtype: None
        '''
        ret_id = rp[0]
        try:
            worker = self._workers[ret_id]
            if worker.is_alive():
                worker.on_heartbeat()
        except KeyError:
            # ignore HB for unknown worker
            pass
        return

    def on_disconnect(self, rp, message):
        '''
            Process worker DISCONNECT command.

            Unregisters the worker who sent this message.

            :param rp:  return address stack
            :type rp:   list of str
            :param message: message parts
            :type message:  list of str

            :rtype: None
        '''
        wid = rp[0]
        self.unregister_worker(wid)
        return

    def on_mmi(self, rp, service, message):
        '''
            Process MMI request.

            For now only mmi.service is handled.

            :param rp:      return address stack
            :type rp:       list of str
            :param service: the protocol id sent
            :type service:  str
            :param message:     message parts
            :type message:      list of str

            :rtype: None
        '''
        if service == b'mmi.service':
            s = message[0]
            ret = b'404'
            for wr in self._workers.values():
                if s == wr.service:
                    ret = b'200'
                    break
            self.client_response(rp, service, [ret])
        else:
            self.client_response(rp, service, [b'501'])
        return

    def on_client(self, proto, rp, message):
        '''
            Method called on client message.

            Frame 0 of message is the requested service.
            The remaining frames are the request to forward to the worker.

            .. note::

               If the service is unknown to the broker the message is
               ignored.

            .. note::

               If currently no worker is available for a known service,
               the message is queued for later delivery.

            If a worker is available for the requested service, the
            message is repackaged and sent to the worker. The worker in
            question is removed from the pool of available workers.

            If the service name starts with 'mmi.', the message is passed to
            the internal MMI_ handler.

            .. _MMI: http://rfc.zeromq.org/spec:8

            :param proto: the protocol id sent
            :type proto:  str
            :param rp:    return address stack
            :type rp:     list of str
            :param message:   message parts
            :type message:    list of str

            :rtype: None
        '''
        service = message.pop(0)
        if service.startswith(b'mmi.'):
            self.on_mmi(rp, service, message)
            return
        try:
            wq, wr = self._services[service]
            wid = wq.get()
            if not wid:
                # no worker ready
                # queue message
                message.insert(0, service)
                wr.append((proto, rp, message))
                return
            wrep = self._workers[wid]
            to_send = [ wrep.id, b'', self.WORKER_PROTO, b'\x02']
            to_send.extend(rp)
            to_send.append(b'')
            to_send.extend(message)
            self.main_stream.send_multipart(to_send)
        except KeyError:
            # unknwon service
            # ignore request
            print 'broker has no service "%s"' % service
        return

    def on_worker(self, proto, rp, message):
        '''
            Method called on worker message.

            Frame 0 of message is the command id.
            The remaining frames depend on the command.

            This method determines the command sent by the worker and
            calls the appropriate method. If the command is unknown the
            message is ignored and a DISCONNECT is sent.

            :param proto: the protocol id sent
            :type proto:  str
            :param rp:  return address stack
            :type rp:   list of str
            :param message: message parts
            :type message:  list of str

            :rtype: None
        '''
        cmd = message.pop(0)
        if cmd in self._worker_cmds:
            fnc = self._worker_cmds[cmd]
            fnc(rp, message)
        else:
            # ignore unknown command
            # DISCONNECT worker
            self.disconnect(rp[0])
        return

    def on_message(self, message):
        '''
            Processes given message.

            Decides what kind of message it is -- client or worker -- and
            calls the appropriate method. If unknown, the message is
            ignored.

            :param message: message parts
            :type message:  list of str

            :rtype: None
        '''
        rp, message = split_address(message)
        # dispatch on first frame after path
        t = message.pop(0)
        if t.startswith(b'OPW'):
            self.on_worker(t, rp, message)
        elif t.startswith(b'OPC'):
            self.on_client(t, rp, message)
        else:
            print 'Broker unknown Protocol: "%s"' % t
        return


class WorkerRep(object):
    '''
        Helper class to represent a worker in the broker.

        Instances of this class are used to track the state of the attached worker
        and carry the timers for incomming and outgoing heartbeats.

        :param proto:    the worker protocol id.
        :type wid:       str
        :param wid:      the worker id.
        :type wid:       str
        :param service:  service this worker serves
        :type service:   str
        :param stream:   the ZMQStream used to send messages
        :type stream:    ZMQStream
    '''

    def __init__(self, proto, wid, service, stream):
        self.proto = proto
        self.id = wid
        self.service = service
        self.current_liveness = HB_LIVENESS
        self.stream = stream
        self.last_hb = 0
        self.hb_out_timer = PeriodicCallback(self.send_hb, HB_INTERVAL)
        self.hb_out_timer.start()
        return

    def send_hb(self):
        '''
            Called on every HB_INTERVAL.

            Decrements the current liveness by one.

            Sends heartbeat to worker.
        '''
        self.current_liveness -= 1
        message = [ self.id, b'', self.proto, b'\x04' ]
        self.stream.send_multipart(message)
        return

    def on_heartbeat(self):
        '''
            Called when a heartbeat message from the worker was received.

            Sets current liveness to HB_LIVENESS.
        '''
        self.current_liveness = HB_LIVENESS
        return

    def is_alive(self):
        '''
            Returns True when the worker is considered alive.
        '''
        return self.current_liveness > 0

    def shutdown(self):
        '''
            Cleanup worker.

            Stops timer.
        '''
        self.hb_out_timer.stop()
        self.hb_out_timer = None
        self.stream = None
        return


class ServiceQueue(object):
    '''
        Class defining the Queue interface for workers for a service.

        The methods on this class are the only ones used by the broker.
    '''

    def __init__(self):
        '''
            Initialize queue instance.
        '''
        self.q = []
        return

    def __contains__(self, wid):
        '''
            Check if given worker id is already in queue.

            :param wid:    the workers id
            :type wid:     str
            :rtype:        bool
        '''
        return wid in self.q

    def __len__(self):
        return len(self.q)

    def remove(self, wid):
        try:
            self.q.remove(wid)
        except ValueError:
            pass
        return

    def put(self, wid, *args, **kwargs):
        if wid not in self.q:
            self.q.append(wid)
        return

    def get(self):
        if not self.q:
            return None
        return self.q.pop(0)


if __name__ == '__main__':

    class MyProxy(OverlordProxy):
        pass

    context = zmq.Context()
    proxy = MyProxy(context, "tcp://127.0.0.1:5555")
    IOLoop.instance().start()
    proxy.shutdown()