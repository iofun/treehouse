# -*- coding: utf-8 -*-
'''
    The treehouse spontaneously generates imps, which are used to spawn your resources.

    Nodes allow control of additional CPU and GPU units.

    Nodes provide control for your cloud forest. 
    As your forces grow in number, you must spawn more nodes to control them.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import os
import zmq
import sys
import uuid
import itertools
import logging
import arrow
import riak
import queries
import pylibmc as mc
import ujson as json
from subprocess import Popen, PIPE
from tornado.ioloop import PeriodicCallback as Cast
from tornado import gen, web
from tornado import websocket
from tornado import queues                                          # <---------------------------------------
from treehouse.tools import options, periodic, new_resource
from treehouse.handlers import imps
from treehouse.handlers import nodes
from treehouse.handlers import indexes
from zmq.eventloop.future import Context, Poller
from zmq.eventloop import ioloop


# hack ioloop for zmq y'all <3
ioloop.install()
# iofun testing box
iofun = []


class TreeWSHandler(websocket.WebSocketHandler):
    '''
        Websocket Handler
    '''

    def get_compression_options(self):
        # Non-None enables compression with default options.
        return {}
    
    def open(self):
        if self not in iofun:
            iofun.append(self)

    def on_close(self):
        if self in iofun:
            iofun.remove(self)


def ws_send(message):
    '''
        Websocket send message
    '''
    for ws in iofun:
        if not ws.ws_connection.stream.socket:
            logging.error("Web socket does not exist anymore!!!")
            iofun.remove(ws)
        else:
            ws.write_message(message)
    if not iofun:
        # logging.info('there are no ws connections at this time')
        pass

@gen.coroutine
def periodic_ws_send():
    '''
        Periodic websocket send
    '''
    hb_time = arrow.utcnow()
    heartbeat = {"heartbeat":{"time":hb_time.timestamp, "info": "periodic_ws_send"}}
    message = json.dumps({'message':heartbeat})
    ws_send(message)

def main():
    # daemon options
    opts = options.options()
    system_uuid = uuid.uuid4()
    # Set treehouse release
    otp_rel = opts.otp_rel
    # count von count
    von_count = 0
    # what if it works?
    @gen.coroutine
    def check_tree():
        os.environ['HOME'] = '/opt/treehouse/'
        process = Popen([otp_rel, "ping", "."], stdout=PIPE)
        (output, err) = process.communicate()
        exit_code = process.wait()
        max_count = 5
        if 'not responding to pings' in output:
            logging.error(output)
            process = Popen([otp_rel, "start", "."], stdout=PIPE)
            (output, err) = process.communicate()
            exit_code = process.wait()
        elif 'pong' in output:
            # pong!
            pass
        else:
            von_count += 1
            if von_count > max_count:
                # Crash circusd monitor
                circus = Popen(["/etc/init.d/circusd", "stop", "."], stdout=PIPE)
                (output, err) = circus.communicate()
                logging.error('we crash circusd after trying {0} times!'.format(max_count))
    # Set memcached backend
    cache = mc.Client(
        [opts.memcached_host],
        binary=opts.memcached_binary,
        behaviors={
            "tcp_nodelay": opts.memcached_tcp_nodelay,
            "ketama": opts.memcached_ketama
        }
    )
    # Set SQL URI
    postgresql_uri = queries.uri(
        host=opts.sql_host,
        port=opts.sql_port,
        dbname='forge',
        user=opts.sql_user,
        password=None
    )
    # Set SQL session
    sql = queries.TornadoSession(uri=postgresql_uri)
    # logging system spawned
    logging.info('Treehouse system {0} spawned'.format(system_uuid))
    # logging database hosts
    logging.info('PostgreSQL server: {0}:{1}'.format(opts.sql_host, opts.sql_port))
    # system cache
    cache_enabled = opts.cache_enabled
    if cache_enabled:
        logging.info('Memcached server: {0}:{1}'.format(opts.memcached_host, opts.memcached_port))
    # treehouse web application daemon
    application = web.Application(
        [
            # experiment with websockets and messaging backbone.
            (r'/ws/alerts', TreeWSHandler),
            # Units resource
            (r'/imps/(?P<imp_uuid>.+)/?', imps.Handler),
            (r'/imps/?', imps.Handler),
            # Nodes resource
            (r'/nodes/(?P<node_uuid>.+)/?', nodes.Handler),
            (r'/nodes/?', nodes.Handler),
            # Indexes resource
            (r'/indexes/(?P<index_uuid>.+)/?', indexes.Handler),
            (r'/indexes/?', indexes.Handler),
        ],
        # system cache
        cache=cache,
        # cache enabled flag
        cache_enabled=cache_enabled,
        # kvalue datastorage
        kvalue=kvalue,
        # sql datastorage
        sql=sql,
        # debug mode
        debug=opts.debug,
        # application domain
        domain=opts.domain,
        # pagination page size
        page_size=opts.page_size,
    )
    # Treehouse periodic cast callbacks
    check_node_tree = PeriodicCast(check_tree, 5000)
    check_node_tree.start()
    # Setting up treehouse processor
    application.listen(opts.port)
    logging.info('Listening on http://%s:%s' % (opts.host, opts.port))
    loop = ioloop.IOLoop.instance()
    # Process heartbeat SUB/PUB
    #loop.add_callback(subscriber)
    #loop.add_callback(publisher, opts.treehouse_host)
    loop.start()

if __name__ == '__main__':
    main()