#!/usr/bin/env python

import zmq

from zmq.eventloop import ioloop
from zmq.eventloop.future import Context, Poller

import logging

from tornado import httpclient as _http_client
from tornado import gen
import ujson as json
import arrow
import uuid


ioloop.install()


@gen.coroutine
def publisher(port=8135):
    '''
        Publisher connect with heartbeat
    '''
    context = Context()
    pub_uuid = str(uuid.uuid4())
    pub = context.socket(zmq.PUB)
    pub.connect("tcp://localhost:%s" % port)

    poller = Poller()
    poller.register(pub, zmq.POLLOUT)

    while True:
        topic = 'heartbeat'
        utc = arrow.utcnow()
        raw = json.dumps({"timestamp":utc.timestamp, "uuid": pub_uuid})
        message = '{0} {1}'.format(topic, raw)

        yield pub.send(message)
        yield gen.sleep(1)

def main():
    '''
        main function
    '''
    loop = ioloop.IOLoop.instance()
    loop.add_callback(publisher)
    loop.start()

if __name__ == '__main__':
    main()