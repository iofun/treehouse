# -*- coding: utf-8 -*-
'''
    The forest spontaneously generates units used to spawn your resources.

    Nodes allow control of additional CPU and GPU units.

    Nodes provide control for your cloud forest.

    As your forces grow in number, you must spawn more nodes to control them.
'''

# This file is part of monteverde.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

# Check our research and resources at the https://nonsense.ws laboratory.

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
import sys
import uuid
import logging
import arrow
import riak
import queries
import pylibmc as mc
import ujson as json
from subprocess import Popen, PIPE
from tornado.ioloop import PeriodicCallback as Cast
from tornado import gen, web
from tornado import httpclient
from monteverde.tools import options, periodic
from monteverde.handlers import units, nodes


httpclient.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')


def main():
    # daemon options
    opts = options.options()
    # System uuid
    system_uuid = uuid.uuid4()
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
        dbname='monteverde',
        user=opts.sql_user,
        password=None
    )
    # Set SQL session
    sql = queries.TornadoSession(uri=postgresql_uri)
    # key-value
    kvalue = riak.RiakClient(host=opts.riak_host, pb_port=8087)
    # Set monteverde OTP release
    erlang_release = opts.erlang_release

    @gen.coroutine
    def check_alive_erlang_node():
        '''
            Checks for an active Erlang/OTP monteverde node
        '''
        os.environ['HOME'] = '/opt/monteverde/'
        process = Popen([erlang_release, "ping", "."], stdout=PIPE)
        (output, err) = process.communicate()
        exit_code = process.wait()
        # some local variables
        max_count,von_count,running = 5,0,False
        if b'not responding to pings' in output:
            logging.error(output)
            process = Popen([erlang_release, "start", "."], stdout=PIPE)
            (output, err) = process.communicate()
            exit_code = process.wait()
            logging.error(output)
        elif b'pong' in output:
            if not running:
                logging.warning('pong!')
                running = True
        else:
            von_count += 1
            if von_count > max_count:
                # Crash circusd monitor cuz why not! right?
                circus = Popen(["/etc/init.d/circusd", "stop", "."], stdout=PIPE)
                (output, err) = circus.communicate()
                logging.error('we crash circusd after trying {0} times!'.format(max_count))

    # logging system spawned
    logging.info('Monteverde system {0} spawned'.format(system_uuid))
    # logging database hosts
    logging.info('PostgreSQL server: {0}:{1}'.format(opts.sql_host, opts.sql_port))
    # solr yokozuna
    logging.info('Solr yokozuna: {0}'.format(opts.solr))
    # logging riak settings
    logging.info('Riak server: {0}:{1}'.format(opts.riak_host, opts.riak_port))
    # system cache
    cache_enabled = opts.cache_enabled
    if cache_enabled:
        logging.info('Memcached server: {0}:{1}'.format(opts.memcached_host, opts.memcached_port))
    # monteverde application daemon
    application = web.Application(
        [
            # Units resource
            (r'/units/page/(?P<page_num>\d+)/?', units.Handler),
            (r'/units/(?P<unit_uuid>.+)/?', units.Handler),
            (r'/units/?', units.Handler),
            # Nodes resource
            (r'/nodes/page/(?P<page_num>\d+)/?', nodes.Handler),
            (r'/nodes/(?P<node_uuid>.+)/?', nodes.Handler),
            (r'/nodes/?', nodes.Handler),

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
        # solr yokozuna
        solr=opts.solr,
    )
    # Periodic Cast Functions
    check_node_tree = Cast(check_alive_erlang_node, 5000)
    check_node_tree.start()
    # Setting up daemon process
    application.listen(opts.port)
    logging.info('Listening on http://%s:%s' % (opts.host, opts.port))
    loop = ioloop.IOLoop.instance()
    loop.start()

if __name__ == '__main__':
    main()
