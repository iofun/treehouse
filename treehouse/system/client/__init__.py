# -*- coding: utf-8 -*-
'''
    Treehouse client logic
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import time
import arrow
import logging
import zmq
import ujson as json
from zmq.eventloop.zmqstream import ZMQStream
from zmq.eventloop import ioloop, zmqstream

from zmq.eventloop.ioloop import IOLoop, DelayedCallback

from zmq.eventloop.future import Context, Poller

from zmq import select

from tornado import gen

from treehouse.system import get_command, process_message


PROTO_VERSION = b'OPC01'


@gen.coroutine
def publisher(port=8899):
    '''
        Please make the publisher the client (connect)

        heartbeat from publisher (the client) every X seconds
    '''
    context = Context()
    pub = context.socket(zmq.PUB)
    pub.connect("tcp://localhost:%s" % port)

    poller = Poller()
    poller.register(pub, zmq.POLLOUT)

    while True:
        topic = 'heartbeat'
        hb_time = arrow.utcnow()
        data = json.dumps({"heartbeat":{"time":hb_time.timestamp, "info": "overlord_uuid"}})

        message = '{0} {1}'.format(topic,data)
        yield pub.send(message)
        yield gen.sleep(1)



def op_request(socket, service, message, timeout=None):
    '''
        Synchronous OP request.

        This function sends a Treehouse protocol request 
        to the given service and waits for a reply.

        If timeout is set and no reply received in the given time
        the function will return None.

        :param socket:    zmq REQ socket to use.
        :type socket:     zmq.Socket
        :param service:   service id to send the message to.
        :type service:    str
        :param message:   list of message parts to send.
        :type message:    list of str
        :param timeout:   time to wait for answer in seconds.
        :type timeout:    float

        :rtype list of str:
    '''
    if not timeout or timeout < 0.0:
        timeout = None
    if type(message) in (bytes, unicode):
        message = [message]
    to_send = [PROTO_VERSION, service]
    to_send.extend(message)
    socket.send_multipart(to_send)
    ret = None
    rlist, _, _ = select([socket], [], [], timeout)
    if rlist and rlist[0] == socket:
        ret = socket.recv_multipart()
        ret.pop(0) # remove service from reply
    return ret


class InvalidStateError(RuntimeError):
    '''
        Exception raised when the requested action is not available due to socket state.
    '''
    pass


class RequestTimeout(UserWarning):
    '''
        Exception raised when the request timed out.
    '''
    pass


class OverlordClient(object):
    '''
        Class for the Treehouse client side.

        Thin asynchronous encapsulation of a zmq.REQ socket.
        Provides a :func:'request' method with optional timeout.

        Objects of this class are ment to be integrated into the
        asynchronous IOLoop of pyzmq.

        :param context:  the ZeroMQ context to create the socket in.
        :type context:   zmq.Context
        :param endpoint: the enpoint to connect to.
        :type endpoint:  str
        :param service:  the service the client should use
        :type service:   str
    '''

    _proto_version = b'OPC01'

    def __init__(self, context, endpoint, service):
        '''
            Initialize the OverlordClient.
        '''
        socket = context.socket(zmq.REQ)
        ioloop = IOLoop.instance()
        self.service = service
        self.endpoint = endpoint
        self.stream = ZMQStream(socket, ioloop)
        self.stream.on_recv(self._on_message)
        self.can_send = True
        self._proto_prefix = [ PROTO_VERSION, service]
        self._tmo = None
        self.timed_out = False
        socket.connect(endpoint)
        return

    def shutdown(self):
        '''
            Method to deactivate the client connection completely.

            Will delete the stream and the underlying socket.

            .. warning:: The instance MUST not be used after :func:'shutdown' has been called.

            :rtype: None
        '''
        if not self.stream:
            return
        self.stream.socket.setsockopt(zmq.LINGER, 0)
        self.stream.socket.close()
        self.stream.close()
        self.stream = None
        return

    def request(self, message, timeout=None):
        '''
            Send the given message.

            :param message:     message parts to send.
            :type message:      list of str
            :param timeout: time to wait in milliseconds.
            :type timeout:  int
            
            :rtype None:
        '''
        if not self.can_send:
            raise InvalidStateError()
        if type(message) in (bytes, unicode):
            message = [message]
        # prepare full message
        to_send = self._proto_prefix[:]
        to_send.extend(message)
        self.stream.send_multipart(to_send)
        self.can_send = False
        if timeout:
            self._start_timeout(timeout)
        return

    def _on_timeout(self):
        '''
            Helper called after timeout.
        '''
        self.timed_out = True
        self._tmo = None
        self.on_timeout()
        return

    def _start_timeout(self, timeout):
        '''
            Helper for starting the timeout.

            :param timeout:  the time to wait in milliseconds.
            :type timeout:   int
        '''
        self._tmo = DelayedCallback(self._on_timeout, timeout)
        self._tmo.start()
        return

    def _on_message(self, message):
        '''
            Helper method called on message receive.

            :param message:   list of message parts.
            :type message:    list of str
        '''
        if self._tmo:
            # disable timout
            self._tmo.stop()
            self._tmo = None
        # setting state before invoking on_message, so we can request from there
        self.can_send = True
        self.on_message(message)
        return

    def on_message(self, message):
        '''
            Public method called when a message arrived.

            .. note:: Does nothing. Should be overloaded!
        '''
        pass

    def on_timeout(self):
        '''
            Public method called when a timeout occured.

            .. note:: Does nothing. Should be overloaded!
        '''
        pass


if __name__ == '__main__':
    
    class MyClient(OverlordClient):

        def on_message(self, message):
            print "Received:", repr(message)
            IOLoop.instance().stop()
            return

        def on_timeout(self):
            print 'TIMEOUT!'
            IOLoop.instance().stop()
            return

    context = zmq.Context()
    socket = context.socket(zmq.REQ)
    socket.setsockopt(zmq.LINGER, 0)
    socket.connect("tcp://127.0.0.1:5555")
    res = op_request(socket, b'echo', [b'TEST'], 2.0)
    if res:
        print "Reply:", repr(res)
    else:
        print 'Timeout!'
    socket.close()