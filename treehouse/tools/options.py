# -*- coding: utf-8 -*-
'''
    Treehouse daemon configuration options.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import os
import base64
import uuid

import tornado.options

from tornado.options import parse_config_file


#secret = base64.b64encode(uuid.uuid4().bytes + uuid.uuid4().bytes)
secret = base64.b64encode("I've said before that I'm a remarkably unsentimental monkey.")
config_path = 'treehouse.conf'


def options():
    '''
        Treehouse configuration options
    '''
    # Startup options
    tornado.options.define(
        'ensure_schemas',
        default=True,
        type=bool,
        help=('Ensure SQL schemas before starting')
    )

    # Set config and stuff
    tornado.options.define(
        'config',
        type=str,
        help='path to config file',
        callback=lambda path: parse_config_file(path, final=False)
    )

    # debugging
    tornado.options.define('debug', default=False, type=bool, help=(
         'Turn on autoreload and log to stderr only'))

    # logging dir
    tornado.options.define('logdir', type=str, default='log', help=(
         'Location of logging (if debug mode is off)'))

    # Application domain
    tornado.options.define('domain', default='iofun.io', type=str,
                            help=('Application domain, e.g. "example.com"')
    )

    # Server settings
    tornado.options.define('host', default='127.0.0.1', type=str,
                           help=('Server hostname'))
    tornado.options.define('port', default=8888, type=int,
                           help=('Server port'))

    # Treehouse node settings
    tornado.options.define('overlord_host', default='127.0.0.1', type=str,
                            help=('Treehouse hostname or ip address'))

    tornado.options.define('overlord_port', default=8899, type=int,
                            help=('Treehouse port'))

    # PostgreSQL database settings
    tornado.options.define('sql_host', type=str,
                            help=('PostgreSQL hostname or ip address'))

    tornado.options.define('sql_port', default=5432, type=int,
                            help=('PostgreSQL port'))

    tornado.options.define('sql_database', type=str,
                            help=('PostgreSQL database'))

    tornado.options.define('sql_user', type=str,
                            help=('PostgreSQL username'))

    tornado.options.define('sql_password', type=str,
                            help=('PostgreSQL username password'))

    # Riak kvalue datastorage settings
    tornado.options.define('riak_host',
        default='127.0.0.1', type=str,
        help=('Riak cluster node'))

    tornado.options.define('riak_port',
        default=8087, type=int,
        help=('Riak cluster port'))

    # Memcached cache datastorage settings
    tornado.options.define('memcached_host',
        default='127.0.0.1', type=str,
        help=('Memcached host'))

    tornado.options.define('memcached_port',
        default=11211, type=int,
        help=('Memcached port'))

    tornado.options.define('memcached_binary',
        default=True, type=bool,
        help=('Memcached binary'))

    tornado.options.define('memcached_tcp_nodelay',
        default=True, type=bool,
        help=('Memcached tcp_nodelay'))

    tornado.options.define('memcached_ketama',
        default=True, type=bool,
        help=('Memcached ketama'))

    tornado.options.define('cache_enabled',
        default=False, type=bool,
        help=('Enable cache'))
    
    # Base url and timezone
    tornado.options.define('base_url', default='api', type=str,
                           help=('Base url, e.g. "api"'))
    tornado.options.define('timezone', type=str, default='America/Costa_Rica',
                           help=('Timezone'))

    # Requests with return settings
    # Pagination - Requests that return multiple items will be paginated
    # to 30 items by default.
    tornado.options.define('page_size', default=30, type=int,
                           help=('Set a custom page size up to 100'))
    tornado.options.define('cookie_secret', default=secret, type=str,
                           help=('Secure cookie secret string'))

    # Parse config file, then command line, so command line switches take
    # precedence
    if os.path.exists(config_path):
        print('Loading %s' % (config_path))

        tornado.options.parse_config_file(config_path)
    else:
        print('No config file at %s' % (config_path))
               
    tornado.options.parse_command_line()
    result = tornado.options.options

    for required in (
        'domain', 'host', 'port', 'timezone', 'base_url',
    ):
        if not result[required]:
            raise Exception('%s required' % required)

    return result