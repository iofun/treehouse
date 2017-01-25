# -*- coding: utf-8 -*-
'''
    Treehouse HTTP Indexes handlers.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import logging

import ujson as json

from tornado import gen, web

from treehouse.system import indexes

from treehouse.tools import errors, str2bool, check_json, content_type_validation

from treehouse.handlers import BaseHandler


@content_type_validation
class Handler(indexes.Index, BaseHandler):
    '''
        Index HTTP request handlers
    '''

    @gen.coroutine
    def post(self):
        '''
            Create index
        '''
        # post structure
        struct = yield check_json(self.request.body)

        # format pass ().
        format_pass = (True if struct and not struct.get('errors') else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return

        # settings database
        db = self.settings.get('db')

        # logging new index structure
        logging.info('new index structure {0}'.format(str(struct)))

        # logging request query arguments
        logging.info('query arguments received {0}'.format(self.request.arguments))

        # request query arguments
        query_args = self.request.arguments

        # get account from new index struct
        account = struct.get('account', None)

        # get the current frontend logged username
        username = self.get_current_username()

        # if the user don't provide an account we use the frontend username as last resort
        account = (query_args.get('account', [username])[0] if not account else account)

        # we use the front-end username as last resort
        if not struct.get('account'):
            struct['account'] = account

        # we're asking the database if the index already exists, if not yield new_index
        check_index = yield self.check_index(struct)

        logging.info('at least tell you that we have a duplicate!')

        if check_index:
            self.set_status(200)
            self.finish({'message':'index already exists'})
            return

        new_index = yield self.new_index(struct)

        if 'error' in new_index:
            scheme = 'index'
            reason = {'duplicates': [
                (scheme, 'name'),
                (scheme, 'index_type')
            ]}
            message = yield self.let_it_crash(struct, scheme, new_index, reason)

            logging.warning(message)
            self.set_status(400)
            self.finish(message)
            return

        self.set_status(201)
        self.finish({'uuid':new_index})