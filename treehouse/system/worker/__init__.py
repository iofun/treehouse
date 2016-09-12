# -*- coding: utf-8 -*-
'''
    Overlord worker logic
'''

# This file is part of overlord.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import sys
import time
import logging

import zmq

from zmq.eventloop.zmqstream import ZMQStream
from zmq.eventloop.ioloop import IOLoop, DelayedCallback, PeriodicCallback


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


class OverlordWorker(object):

    '''
        Class for the Overlord worker side.

        Thin encapsulation of a zmq.DEALER socket.
        Provides a send method with optional timeout parameter.

        Will use a timeout to indicate a proxy failure.
    '''

    _proto_version = b'OPW01' # Overlord Protocol Worker 01

    HB_INTERVAL = 1000  # in milliseconds
    HB_LIVENESS = 3    # HBs to miss before connection counts as dead

    def __init__(self, context, endpoint, service):
        '''
            Initialize the OverlordWorker.

            context is the zmq context to create the socket from.
            service is a byte-string with the service name.
        '''
        self.context = context
        self.endpoint = endpoint
        self.service = service
        self.stream = None
        self._tmo = None
        self.need_handshake = True
        self.heartbeat = None
        self._delayed_cb = None
        self._create_stream()
        return

    def _create_stream(self):
        '''
            Helper to create the socket and the stream.
        '''
        socket = self.context.socket(zmq.DEALER)
        ioloop = IOLoop.instance()
        self.stream = ZMQStream(socket, ioloop)
        self.stream.on_recv(self._on_message)
        self.stream.socket.setsockopt(zmq.LINGER, 0)
        self.stream.connect(self.endpoint)
        self.heartbeat = PeriodicCallback(self._heartbeat, self.HB_INTERVAL)
        self._send_ready()
        self.heartbeat.start()
        return

    def _send_ready(self):
        '''
            Helper method to prepare and send the workers READY message.
        '''
        ready_message = [ b'', self._proto_version, b'\x01', self.service ]
        self.stream.send_multipart(ready_message)
        self.current_liveness = self.HB_LIVENESS
        return

    def _heartbeat(self):
        '''
            Method called every HB_INTERVAL milliseconds.
        '''
        self.current_liveness -= 1
        ## print '%.3f tick - %d' % (time.time(), self.current_liveness)
        self.send_hb()
        if self.current_liveness >= 0:
            return
        ## print '%.3f lost connection' % time.time()
        # ouch, connection seems to be dead
        self.shutdown()
        # try to recreate it
        self._delayed_cb = DelayedCallback(self._create_stream, 5000)
        self._delayed_cb.start()
        return

    def send_hb(self):
        '''
            Construct and send HB message to broker.
        '''
        message = [ b'', self._proto_version, b'\x04' ]
        self.stream.send_multipart(message)
        return

    def shutdown(self):
        '''
            Method to deactivate the worker connection completely.

            Will delete the stream and the underlying socket.
        '''
        if self.heartbeat:
            self.heartbeat.stop()
            self.heartbeat = None
        if not self.stream:
            return
        self.stream.socket.close()
        self.stream.close()
        self.stream = None
        self.timed_out = False
        self.need_handshake = True
        self.connected = False
        return

    def reply(self, message):
        '''
            Send the given message.

            message can either be a byte-string or a list of byte-strings.
        '''
##         if self.need_handshake:
##             raise ConnectionNotReadyError()
        # prepare full message
        to_send = self.envelope
        self.envelope = None
        if isinstance(message, list):
            to_send.extend(message)
        else:
            to_send.append(message)
        self.stream.send_multipart(to_send)
        return

    def _on_message(self, message):
        '''
            Helper method called on message receive.

            message is a list w/ the message parts
        '''
        # 1st part is empty
        message.pop(0)
        # 2nd part is protocol version
        # TODO: version check
        proto = message.pop(0)
        # 3rd part is message type
        message_type = message.pop(0)
        # XXX: hardcoded message types!
        # any message resets the liveness counter
        self.need_handshake = False
        self.current_liveness = self.HB_LIVENESS
        if message_type == b'\x05': # disconnect
            self.current_liveness = 0 # reconnect will be triggered by hb timer
        elif message_type == b'\x02': # request
            # remaining parts are the user message
            envelope, message = split_address(message)
            envelope.append(b'')
            envelope = [ b'', self._proto_version, b'\x03'] + envelope # REPLY
            self.envelope = envelope
            self.on_request(message)
        else:
            # invalid message
            # ignored
            pass
        return

    def on_request(self, message):
        '''
            Public method called when a request arrived.

            Must be overloaded!
        '''
        pass


# workers could be think of members of a processing pool or task force.

def worker_task(ident):
    '''
        Worker task, using a REQ socket to do load-balancing.
    '''
    # When the new ZMQ client and server sockets are stable
    # we need to change sockets here.
    context = zmq.Context()
    socket_req = context.socket(zmq.REQ)
    socket_req.identity = u"Worker-{}".format(ident).encode("ascii")
    socket_req.connect("tcp://localhost:%s" % '4188')
    stream_req = zmqstream.ZMQStream(socket_req)
    # Tell broker we're ready for work
    socket_req.send(b"READY")

    while True:
        address, empty, request = socket_req.recv_multipart()
        logging.warning("{}: {}".format(socket_req.identity.decode("ascii"),
                              request.decode("ascii")))
        socket_req.send_multipart([address, b"", b"WORLD"])


if __name__ == '__main__':

    import zmq
    from zmq.eventloop.ioloop import IOLoop
    

    class MyWorker(OverlordWorker):

        HB_INTERVAL = 1000
        HB_LIVENESS = 3

        count = 0

        def on_request(self, message):
            self.count = self.count + 1
            self.reply(message)
            return
    

    context = zmq.Context()
    worker = MyWorker(context, "tcp://127.0.0.1:5555", b"echo")
    IOLoop.instance().start()
    worker.shutdown()