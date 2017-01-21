#!/usr/bin/env python

import zmq
from zmq.eventloop import ioloop
from zmq.eventloop.future import Context, Poller
from tornado import gen
import ujson as json
import arrow
import uuid

ioloop.install()

@gen.coroutine
def publisher(port=5813):
    context = Context()
    pub_uuid = str(uuid.uuid4())
    pub = context.socket(zmq.PUB)
    pub.connect("tcp://zmq.nonsense.ws:%s" % port)
    poller = Poller()
    poller.register(pub, zmq.POLLOUT)
    while True:
        topic = 'heartbeat'
        utc = arrow.utcnow()
        raw = json.dumps({"timestamp":str(utc.timestamp), "uuid": pub_uuid})
        message = '{0} {1}'.format(topic, raw)
        yield pub.send(message)
        yield gen.sleep(1)

def main():
    loop = ioloop.IOLoop.instance()
    loop.add_callback(publisher)
    loop.start()

if __name__ == '__main__':
    main()
