# -*- coding: utf-8 -*-
'''
    Overlord server logic
'''

# This file is part of overlord.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import uuid
import random
import logging
import zmq
import time
import arrow
import psutil
from tornado import gen
from zmq.eventloop import ioloop

from zmq.eventloop.zmqstream import ZMQStream
from zmq.eventloop.future import Context, Poller
from zmq.log.handlers import PUBHandler

from overlord.system import process_message

@gen.coroutine
def subscriber(port=8899):
    '''
        ZMQ Subscriber
    '''
    logging.warning("Binding SUB socket on port: {0}".format(port))
    context = Context()
    sub = context.socket(zmq.SUB)
    sub.bind("tcp://*:%s" % port)

    sub.setsockopt(zmq.SUBSCRIBE, "heartbeat")
    sub.setsockopt(zmq.SUBSCRIBE, "asterisk")
    sub.setsockopt(zmq.SUBSCRIBE, "binary")
    sub.setsockopt(zmq.SUBSCRIBE, "logging")
    sub.setsockopt(zmq.SUBSCRIBE, "upload")

    http_client = httpclient.AsyncHTTPClient()


    def handle_binary_request(response):
        '''
            Binary Request Handler
        '''
        if response.error:
            logging.error(response.error)
        else:
            #logging.info('binary acknowledgement %s' % str(response.body))
            # -- do nothing
            pass
            


    poller = Poller()
    poller.register(sub, zmq.POLLIN)
    while True:
        events = yield poller.poll(timeout=1000)
        if sub in dict(events):

            msg = yield sub.recv()

            if msg.startswith('heartbeat'):

                # heartbeats are fucking important report heartbeats to the DHT or explore more on wtf do you mean abut that. 

                # for now do nothing
                msg = msg.split(' ')[1]
                # websocket send
                try:
                    msg = json.loads(msg)
                except Exception, e:
                    logging.error(e)
                #ws_send(json.dumps({'message':msg}))
            elif msg.startswith('asterisk'):
                msg = msg.split(' ')[1]
                # websocket send of asterisk messages, why are we doing this???
                # I think is something about the calls so check it out witch howler and anthony
                ws_send(msg)
            elif msg.startswith('binary'):

                # -- report currency on extractor
                message = msg.split(' ')[1]
                # -- http_client
                http_client.fetch(
                    'http://fun.codemachine.io/currencies/', 
                    headers={"Content-Type": "application/json"},
                    method='POST',
                    body=msg.split(' ')[1],
                    callback=handle_binary_request
                )

                # WHY THE FUCK ARE WE SENDING THIS INSIDE A WS???

                # websocket send
                #ws_send(json.dumps({'message':json.loads(message)}))

                # -- do nothing

            elif msg.startswith('logging'):
                pass
            elif msg.startswith('upload'):
                msg = msg.split(' ')[1]
                
                # -- do nothing
        else:
            #logging.info('nothing to recv')
            pass

# @gen.coroutine
# def subscriber(port=8899):
#     '''
#         ZMQ Subscriber
#     '''
#     logging.warning("Binding SUB socket on port: {0}".format(port))
#     context = Context()
#     sub = context.socket(zmq.SUB)
#     sub.bind("tcp://*:%s" % port)

#     sub.setsockopt(zmq.SUBSCRIBE, "heartbeat")
#     sub.setsockopt(zmq.SUBSCRIBE, "asterisk")
#     sub.setsockopt(zmq.SUBSCRIBE, "logging")
#     sub.setsockopt(zmq.SUBSCRIBE, "upload")

#     poller = Poller()
#     poller.register(sub, zmq.POLLIN)
#     while True:
#         events = yield poller.poll(timeout=500)
#         if sub in dict(events):
#             #logging.info(msg)
#             msg = yield sub.recv()
#             if msg.startswith('heartbeat'):
#                 msg = msg.split(' ')[1]
#                 # websocket send
#                 wsSend({'message':msg})
#             elif msg.startswith('asterisk'):
#                 msg = msg.split(' ')[1]
#                 # websocket send
#                 wsSend(msg)
#             elif msg.startswith('upload'):
#                 msg = msg.split(' ')[1]
#                 # websocket send
#                 wsSend(msg)
#             elif msg.startswith('logging'):
#                 pass
#         else:
#             #logging.info('nothing to recv')
#             pass



# the next stuff is bananas


def pusher(port="5556"):
    '''
        Control process

        PUSH node control
    '''
    # Please explain with more detail how the control process/context/socket works.

    context = zmq.Context()
    socket = context.socket(zmq.PUSH)
    socket.bind("tcp://*:%s" % port)
    logging.warning("Running PUSH server on port: {0}".format(port))
    message = 'Continue'
    # serves only 5 request and dies
    while message == 'Continue':
        socket.send(message)
        time.sleep(1)
    socket.send("Exit")


def publisher(port="5558"):
    '''
        Monitor process

        PUB node monitor

        How this publisher can be used as Monitor process?
        publishers send messages fron one or more topics to a subscriber.

        how can we monitor something from a perspective of the one that sends input
        to a remote location subscriber ... 
    '''
    context = zmq.Context()
    socket = context.socket(zmq.PUB)
    socket.bind("tcp://*:%s" % port)

    publisher_id = random.randrange(0,9999)
    spawn_uuid = uuid.uuid4()
    logging.warning("Running PUB server process on port: {0}".format(port))

    while True:
        # Wait for next request from client

        topic = random.randrange(8,10)
        messagedata = "server#{0}".format(publisher_id)
        message = "{0} {1}".format(topic, messagedata)
        socket.send(message)

        topic = 'information'
        messagedata = "server#{0}".format(spawn_uuid)
        message = "{0} {1}".format(topic, messagedata)
        socket.send(message)

        wut = arrow.utcnow()
        mem = psutil.virtual_memory()
        ctm = psutil.cpu_times()
        sss = psutil.cpu_percent(interval=None, percpu=True)

        topic = 0
        messagedata = '{0} overlord#{1} Overlord CPU {2} Memory {3} Times {4}'.format(wut,spawn_uuid,sss,mem,ctm)
        message = "{0} {1}".format(topic, messagedata)
        socket.send(message)
        time.sleep(1)


def router(frontend_port, backend_port):
    '''
        ROUTER engine process
    '''

    def process_frontend_client(message):
        '''
            Process frontend client request
        '''
        logging.warning("Processing frontend message ... {0}".format(message))
        # Get next client request, route to last-used worker
        client, empty, request = message
        if not workers:
            # Don't poll clients if no workers are available
            logging.warning("Don't poll clients if no workers are available")
            logging.error(message)
        else:
            worker = workers.pop(0)
            message = [worker, b"", client, b"", request]
            logging.warning('message {0}'.format(message))
            backend.send_multipart(message)

    def process_backend_server(message):
        '''
            Process backend
        '''
        logging.warning("Processing backend message ... {0}".format(message))
        worker, empty, client = message[:3]
        workers.append(worker)
        if client != b"READY" and len(message) > 3:
            # If client reply, send rest back to frontend
            empty, reply = message[3:]
            frontend.send_multipart([client, b"", reply])
        logging.warning('Current workers {0}'.format(workers))

    # Prepare context and sockets
    context = zmq.Context()
    # define backend context and socket
    backend = context.socket(zmq.ROUTER)
    backend.bind("tcp://*:{0}".format(backend_port))
    # prepare backend stream
    backend_stream = ZMQStream(backend)
    backend_stream.on_recv(process_backend_server)
    logging.warning("Bind workers router on port {0}".format(backend_port))
    # define frontend context and socket
    frontend = context.socket(zmq.ROUTER)
    frontend.bind("tcp://*:{0}".format(frontend_port))
    # prepare frontend stream
    frontend_stream = ZMQStream(frontend)
    frontend_stream.on_recv(process_frontend_client)
    logging.warning("Bind clients router on port {0}".format(frontend_port))
    # instance ioloop
    ioloop.IOLoop.instance().start()