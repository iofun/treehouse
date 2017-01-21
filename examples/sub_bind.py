#!/usr/bin/env python

import logging, uuid, zmq

from zmq.eventloop import ioloop
from zmq.eventloop.future import Context, Poller

from tornado import httpclient as _http_client
from tornado import gen
import ujson as json

ioloop.install()

@gen.coroutine
def subscriber(port=5813):
    '''
        Bind Subscriber
    '''
    logging.warning("Binding SUB socket on port: {0}".format(port))
    context = Context()
    sub = context.socket(zmq.SUB)
    sub.bind("tcp://*:%s" % port)

    sub.setsockopt(zmq.SUBSCRIBE, " ")
    sub.setsockopt(zmq.SUBSCRIBE, "heartbeat")
    sub.setsockopt(zmq.SUBSCRIBE, "asterisk")
    sub.setsockopt(zmq.SUBSCRIBE, "logging")
    sub.setsockopt(zmq.SUBSCRIBE, "upload")
    sub.setsockopt(zmq.SUBSCRIBE, "beam")

    poller = Poller()
    poller.register(sub, zmq.POLLIN)

    http_client = _http_client.AsyncHTTPClient()

    while True:
        events = yield poller.poll(timeout=1000)
        if sub in dict(events):
            # receive raw msg from sub
            msg = yield sub.recv()
            # get topic and message
            topic = msg.split(' ')[0]
            message = ' '.join(msg.split(' ')[1:])
            # this make more sense directly on the beam
            # that why we're moving, still this sub_bind.py
            # clear some ideas directly.
            if topic.startswith('heartbeat'):
                print(topic, message)
            elif topic.startswith('asterisk'):
                print(topic, message)
            elif topic.startswith('logging'):
                print(topic, message)
            elif topic.startswith('upload'):
                print(topic, message)
            elif topic.startswith('beam'):
                print(topic, message)
            else:
                # let it crash
                logging.warning('let it crash')
                print(msg)
        else:
            #logging.warning('nothing receive')
            pass

def main():
    '''
        main function
    '''
    loop = ioloop.IOLoop.instance()
    loop.add_callback(subscriber)
    loop.start()

if __name__ == '__main__':
    main()