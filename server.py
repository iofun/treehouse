# -*- coding: utf-8 -*-
'''
    The treehouse spontaneously generates units, which are used to spawn your resources.

    Nodes allow control of additional CPU and GPU units.

    Nodes provide control for your cloud forest. 
    As your forces grow in number, you must spawn more nodes to control them.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

# Check out our research, services and resources at the https://nonsense.ws laboratory.

__ooo__ = '''

    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░╔░Ñß╠░░░░░░░░░░░░░░░░░░░░░░░»░░░░░░░░░░░░░░░░░░░░░
    ░░µ▄▄▄»░╔▄░░▄▄▄▄▄▄▄▄░░░ú░░░░░░░╔φm╫▒░╔▄░░▄░░▄╔░»▄▄»░░░░░µ░░▄▄▄▄▄▄▄▄▄▄▄▄░░▄░░▄H░░
    ░░║██▀░░░¼░░██████████▄x░]░µúµ╙▀▓▓▓░░░░░░╠░░╢▓╠░╠░¡µ»╗╩Ü░░▄█████████▀▀╫░░░░░╙▌░░
    ░░║░»╩░░░░░░░██████░░╙╠▀▄░░░╟╫╬Ñ▓▓▓░░╟░░░░░»░▓▓╫▓╫▌░µ▄▄╦╨▀▀╠░║█████░░░Ü░░░Üµ░»░░
    »░║▌h░░░░╠░░░███▄╙▀░Ñ╔░░Ü▀▓▓▓╫╫╫▓╫╫▌░µ░░░╟╔▄▓╫╫▓╫╫▓▓▓▀U░½µK╜ñ╙▀Ü»╨║█ñµ]░░░M░░µ░░
    ░░║█░╠▄░░▄▄░║███▀░░░░░»░╦░╔▓╫╫▓▓▓╫╫╫░▄╫░µ╙╫╫▓╫╫▓▓▓╫╫▓N▄Å░░░░░µ╩██▄██░▄▄▌░▓█▄▄▌░░
    ░░║█████╔██████▓▄░«░╦░░░░╙▓╫╫╫▓▓╫╫╫╫▓╫▓▌µñU╬╫▓╫╫╫▓╫╫▓▀░░░µ»m╠░║█████████░████▌░░
    h░║███████████████▄▄▄▄╬▓▌░╥▀╣▓╫╫╫╫╫»Ñ╠▀▓╬▓▓╫▓░╙▀╩╬▓▓╬▓▓╫░╠»U▄▄███████████████▌░░
    ░░║███████████████╫▓▓▓╫╫▓╫╬▓▀░hU╠Å▀░ñ╟╫╫M╠▀▀▀H«U╔░µ░╙╫╫╫▓▓╫╫╫╫███████████████▌░░
    »░║████╫██████████╫▓╫▓▓▓▓╫▌░░m░»»░░µ╙▀▓╫▓╩U▄φ░░░░╚░ñ░▄╫╫╫╫▓▓╫╫▓╫╫██████╫╫████▌░░
    ░░║█╫╫█▓╫█▓╫██╫▓╫╫▓▓▓╫▓╫╫╫╫▓░░░░µ≈Ü░░▄╣▓▓╫▓╫▓░Hµ░░░░╙╫╫╫▓╫▓╫▓▓╫▓███╫╫╫▓▓▓╫▓╫╫▌░░
    »░░╫╫╫╫▓▓╫╫╫╫█▓▀▀╨║╫█▓▓▓▓▓Ü▄╬╬░╟░½░╫▓╫▓▓▓▓▓╫╫▌½░░╠░▓▓▓╦▓╫╫╫▓╫▌▀▀▓██▓╫╫╫▓▓▓▓╫╫▌░░
    ░░╟╫╫╫╫▓▓▓▓╫▀░░U░U║╩▀╠▓╫╫╫╫╫▓▓▓▄╦▓█╢╫╫▓▓▓▓▓╫▓▓╠▀╬▓N▓▓▓▓▓▓▓▀▀▀U░░╠░░╢╫╫▓▓▓╫╫▓▀U░░
    »░░║╫╫▓╫╫▓Ü░«µ░░»░░░╝▓╫╫╫▓╫▓▓▓▓▓╫▓▓╙╫╫█▓▓▓▓╫╫M⌂╠▄▓▓▓▓▓╫▓▓▓╫▓░░░░░╙h╠╫╫▓▓╫▓░░░░░░
    »░»╙╫╙╦╟╫╫▓N░»░░»»D░h╦╟╫▓▓╫╫╫▓╫░≈╠»░▀░µ╙╫▌░⌂Ü░░▀▓╫╫▓▓╫▓▓▓╫▌░≈░╦µ░░░░╠»╫╙▓▓▓▓░░░░
    ░»»╦▓╦ô░▓█▀░h╟N▄╠░>▄▓█▓▓╫╬╫▓╫╫▀ñ>Ü░»░U»░█»»╠░░░╠µ╙╢▓╫╫███▓▓▓▄░░/░ñ░▓▓▓▓▄█▀░░░▌░░
    ░░░╫╫╫▓▀▓N╫▄D▓╫▓╫╫╫╫████▓▓████▄░ñ░░»»H«╔▌░ñ╠░░h╟«░║██████████╫╫╫▓▓╦╫╫█▀░▓▓▓▓╫▌░░
    ░░╟▓▓░U░╟▓╫▓▓▓▓▓╫╫▓╫╫╫██████████▄▄░░Å░h██░░▄p░╔░h░█████████╫╫▓╫╫╫▓▓╫▓╠░░╟╫▓╝▓Ü░░
    ░░╟╫╫╫▓»░▀░µ║╫╫╫▓▓▓╫╫███████████░░░███▓█████▌µ███▓██████████╫▓▓▓╫▓▓╫╫▓╬░░╠µ░║▌░░
    »░╠▓▀░h░░░⌂»»╫▓╫▓╫╫▓█▓████████▀██▄░████████████▀▀▀██████████▓█▓▓╫▓▓▓░░Ü░░░H░░▓░░
    »░░U░µÜ░░░Ü»░║▓▓█▓▓██████████▌░░╠»░██████████░░░╚░║█▀▀████████╫▓▓██▓Ü»U░░░Å░ñ╟░░
    »h╠╫░»╩░░»░░░▓▓▓▓██████████▄░░░░╙>░░██████▀░µ░¥░░░░░║██████████████╫░ñ░⌂░µ▄░░▓░░
    »░╔╫▌╦▓▓░║▓╫▓╫╫▓███████████▀░H░░h░░ñ▀▀▒╜███▓⌐░░░░µ≥░>╔█████████╫╫▓╫▓▓▓╫▓░▓╫▓▓Ñ░░
    »░░▓╫╫╫╫░▓╫╫╫▓▓▓╫██████████▄░µÜ░░╠h▄▄▄]U███░>╓▄▄░h░╠██▀▀███████╫╫▓▓▓╫▓╫╫▓╫╫▓▓▓░░
    »h░▓▓█╫▓▓╫╫╫▓▓▓╫╫╫▓▀▀Ü░░║███████▄▄»▓███▀█▄▄░░║██████▄▒░░██▀▀╙╙╫╫╫╫▓▓▓▓╫╫▓╫╫▓▓▓░░
    »h░▓╫▓╫▓╟╫╫╫╫▓▓▓╫╫░╟≥░░░░░▄▓█████████░m░║█████████████▄░░░░░░╦░╙╩▓▓▓▓╫╫▌║╫╫╫▓▓░░
    »»░▓▀╩▓H░▀▀░▓▓▌╫╩▓╩░░»░µ«░▀▀███████████░░▀▀»║████████░░ñ░░░░░░░▄╗▓╫▓╙▀▀░░╠░░╣╫░░
    h░░Üñ░ó░░░Ü░╜╫»░µ▄▄»╗^░░U░╔█████████▀░╠░░░Ü░╙███████▀██▄░µ░]░µ▄╙▀▓▓░╙░Ñ░░░U»╨▓░░
    »░░░ññU░░░]≥░║▓╫╫╫╫░µ▄╦≡ñ▀▀░U░████▀▌≈░Ü░»░╠»»║█████▌░░░░X▄µ░░▓▓╫▓▓█U░µH░░░ù<░╬░░
    ░h╔▓░µ╠░░░Ü╦▓╫▓▓╫╫╫╫╫▀>⌂ñµÅ░░░╙╠░╫╔█░µ½░░µÜh>▓██▓▄»░░░Ñµ╩╙▀╬╫╫╫╫╫╫▓╫░≈Ñ░░╔▄▓╫▓░░
    »h░╫Mµ╬▓µ╝▀▓╫▓╫▓▓▓╫╫╫╫╦»░░░░░µ║██▄██▌▄██░╫██▓███▀µhU░░░░░Ü▄╫╫╫╫▓▓▓╫╫▄╦▓▓x╙▀╣▓╫░░
    hñ░╫╫▓▓▓▌φ╠╫▓╫╫╫╫▓╫╫▓▀▄▄«╔hU░░██████████▌████████▄░░╠ñ░»µµ▀▓╫╫╫╫╫╫╫▓▓▓╫▓M╩╠▓▓▓░░
    »░░▌╩╠Ü╠▓▓╫╫▓▌»╙▀▀▀█▓▓▓╫░╠▄╦╫╗█████████████████████╫╬▓▓▓╫@K╩╠▓╩╩▓▓╫▌╨░N║▓▓▓▓▓▌░░
    »░░░░▄▓▓▌╬╙╠▀▀»░╟░x░µ▀▓╫▓╫╫▓▓╫╫███████████████████╫╫▓▓╫╫▓▓╫▓▀░Ü░m^╙»░╬█▓▌╠Ü╠╙╙░░
    ░░░╔╙▀█╫╫╨▄╫╣░░░░░ñÜ╔╦▓▓▓▓▓▓▓╫▓▓╫███████▓██╫██████╫╫▓▓▓▓╫╫▓▄░ñ░░░░░╔╙╙▀▓╫╬▓▓╫K░░
    »»░░░▄╬╫▓╫╫╫╫░ñ%U░░░╙▀▓╫╫╫▓╫╫╫▓█████╫╫▓▓▓╫▓╫╫█╫█▓▓╫▓▓╫▓╫▓╫╫▓░;»╔»D░U╔╬▓▓▓▓▓▓╫░░░
    »░░╟▓╫▓▓▓▓▓▓▓▓▄▄░╟░█╫▓▓█▓▓▓▓▓▌╙▀▀▀██╫▓╫▓▓▓▓╫╫█▀░»░║╫╫▓▓╣▓▓▓Φ▓╫▌░m░▄╬╫▓▓▓▓▓▓▓╫▓░░
    »░░╟╫╫▓▓▓▓█▓╫╫╠Å╫╫N▓╫▓▓╫▓▓Ü╙╙░h░╠░U╙╫╫▓▓▓╫╫▓Ü░░½«░░╙»▄▓╫╫╫╫╫▓╫▓▓▓█╫▀╫▓╫╫▓▓▓╫▓▓░░
    »░░░▓╫▓▓▓╫╩▓╫▌U╠▄╬▓╫▓▓▓╫╫╫╫▓M░░░░░ñ»▓╫▓▀╫╫▓¿ñHÜ»░»░╔╙▀╫╫▓╫▓▓▓╫▓▓▀█▓░█╫▓▀╫╫▀▀▓Ü░░
    ░h░░╠░µ╙╫▓«µ░░░╠▀▓╫╫╫▓╫▓▓╫▓░░░ñ>⌂░░░»H╠Ü▓▓╫█▀»░µ>m╙░╔#▓╫╫╫▓╫▓╫╫░ñ╗░░╚«»^╟▌░ñÑ░░░
    hh░░░U»h█░h╗░░░╟%⌂▀▓╫▓▓██▓╫▓N▄▄╔░╠░╟█▓▓╦║▀╠Uµß╫▓N╦▄▓████▓▓╫▓▓▓▌µ░Ü░░»Kñ░╟░░░░░░░
    »░h░░H═╗▌░ñ╟░░░╟ñU╟██████████╫╫╫▓▓╦╫╫▓▀╦╝╫▓▓▓╫╫╫╫▓╫▓╫██████████▄░ì░░»Ü░╠█░µ░░░░░
    »»»░╠ññ██░░▄▄░╔▄░░█████████╫╫▓▓╫▓▓▓╫╫╦▒µm╢█╩▀╫╫╫╫╫╫╫╫╫███████████▀µ░▄▄░║█▌▄▄▓░░░
    »»░║████████▌░██████████████▓╫▓▓╫╫╫▓╫▓╨Ü░░U«░▓╫╫╫╫╫▓╫███████████▄Uµ║█████████░░░
    »h░██████████▄██▀▀╙█████████▓█▓╫╫╫▓▓▀µ╬░░░╟ñ^╙╫╫▓▓╫███████████╙▀▀▀K███████████░░
    »h░██████████▀░½░¼░█▀▀▄████████▓█▓██▒░╩░░░╟░░ñ█████████████▀▀▀░U╟░h╙█████████▀░░
    »h░░██████▀▀U░Nñ░░░░░██████████████╫▓h░▄░░▄▄░║▓▓████████████Kµ░░░░ñU███████░░«░░
    »░h½█▀░╜██▀K»Ü»░░░»╨h░»▀▀█▀█▀▀▀▀▀▀▀▀╩╩▀▀H»▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀»░╨hh░»»/╠░╚ñ║▀▀▀M░░░
    »»»╨╚╙╨░╙╙░╨"!╙░╙╚░╩^^╨^░"h░░""░Ü"░░░^╚"╚╨░»»░░░»░»»░░»»░░»░»»░»»»»»»»»»»░░░░░»»
    
'''

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
from tornado import queues            # <------------------------------------- mae.
from tornado import httpclient
from treehouse.tools import options, periodic, new_resource
from treehouse.handlers import nodes
from treehouse.handlers import indexes
from zmq.eventloop.future import Context, Poller
from zmq.eventloop import ioloop


httpclient.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')


ioloop.install()
# black testing box
blackbox = []


class TreeWSHandler(websocket.WebSocketHandler):
    '''
        WebSocket Handler
    '''

    def get_compression_options(self):
        # Non-None enables compression with default options.
        return {}
    
    def open(self):
        if self not in blackbox:
            blackbox.append(self)

    def on_close(self):
        if self in blackbox:
            blackbox.remove(self)


def ws_send(message):
    '''
        WebSocket Send
    '''
    for ws in blackbox:
        if not ws.ws_connection.stream.socket:
            logging.error("Web socket does not exist anymore!!!")
            blackbox.remove(ws)
        else:
            ws.write_message(message)
    if not blackbox:
        # we choose to ignore it just pass
        pass

@gen.coroutine
def periodic_ws_send():
    '''
        Periodic WebSocket Send
    '''
    hb_time = arrow.utcnow()
    heartbeat = {"heartbeat":{"time":hb_time.timestamp, "info": "periodic_ws_send"}}
    message = json.dumps({'message':heartbeat})
    ws_send(message)

def main():
    # daemon options
    opts = options.options()
    # System uuid
    system_uuid = uuid.uuid4()
    # Set treehouse release
    otp_rel = opts.otp_rel
    # count von count
    von_count = 0

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

    @gen.coroutine
    def check_indexes():
        '''
            Automatically generate SOLR indexes
        '''
        def handle_response(response):
            '''
                Handle response
            '''
            if response.error:
                logging.error(response.error)
            else:
                logging.info(response.body)

        # get this list from pillar or some shit, like from regular configuration file, you know.
        current = [
            'mango_account',
            'mango_task',
            'howler_contact',
            'cas_email',
            'cas_sms',
            'cas_query'
        ]
        # process the current list of indexes
        for i in current:
            # for index in current system
            http_client = httpclient.AsyncHTTPClient()
            http_client.fetch(
                'https://api.cloudforest.ws/indexes/', 
                headers={"Content-Type": "application/json"},
                method='POST',
                body=json.dumps({'name': i, 'index_type': i}),
                callback=handle_response
            )

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
    # key-value
    kvalue = riak.RiakClient(host=opts.riak_host, pb_port=8087)
    # logging system spawned
    logging.info('Treehouse system {0} spawned'.format(system_uuid))
    # logging database hosts
    logging.info('PostgreSQL server: {0}:{1}'.format(opts.sql_host, opts.sql_port))
    # logging riak settings
    logging.info('Riak server: {0}:{1}'.format(opts.riak_host, opts.riak_port))
    # system cache
    cache_enabled = opts.cache_enabled
    if cache_enabled:
        logging.info('Memcached server: {0}:{1}'.format(opts.memcached_host, opts.memcached_port))
    # treehouse application daemon
    application = web.Application(
        [
            # Nodes resource
            (r'/nodes/(?P<node_uuid>.+)/?', nodes.Handler),
            (r'/nodes/?', nodes.Handler),
            # Internal index resources
            (r'/indexes/(?P<index_uuid>.+)/?', indexes.Handler),
            (r'/indexes/?', indexes.Handler),
            # Experiment with WebSockets and the BEAM as message backbone.
            (r'/ws/alerts', TreeWSHandler),
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
    # Periodic Cast Functions
    check_node_tree = Cast(check_tree, 5000)
    check_node_tree.start()
    check_node_indexes = Cast(check_indexes, 180000)
    check_node_indexes.start()
    # Setting up daemon process
    application.listen(opts.port)
    logging.info('Listening on http://%s:%s' % (opts.host, opts.port))
    loop = ioloop.IOLoop.instance()
    # Process heartbeat SUB/PUB
    #loop.add_callback(subscriber)
    #loop.add_callback(publisher, opts.treehouse_host)
    loop.start()

if __name__ == '__main__':
    main()