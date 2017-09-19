# -*- coding: utf-8 -*-
'''
    Treehouse HTTP event handlers.
'''

# This file is part of Treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

import time
import arrow
import uuid
import logging
import urlparse
import ujson as json
from tornado import gen
from tornado import web
from treehouse.messages import nodes as models
from treehouse.system import nodes
from tornado import httpclient
from treehouse.tools import errors, str2bool, check_json, new_resource
from treehouse.handlers import BaseHandler

class Handler(nodes.Node, BaseHandler):
    '''
        HTTP request handlers
    '''

    @gen.coroutine
    def head(self, account=None, node_uuid=None, page_num=0):
        '''
            Head nodes
        '''
        # request query arguments
        query_args = self.request.arguments
        # get the current frontend logged username
        username = self.get_current_username()
        # if the user don't provide an account we use the username
        account = (query_args.get('account', [username])[0] if not account else account)
        # query string checked from string to boolean
        checked = str2bool(str(query_args.get('checked', [False])[0]))
        # getting pagination ready
        page_num = int(query_args.get('page', [page_num])[0])
        # not unique
        unique = query_args.get('unique', False)
        # rage against the finite state machine
        status = 'all'
        # are we done yet?
        done = False
        # some random that crash this shit
        message = {'crashing': True}
        # unique flag activated
        if unique:
            unique_stuff = {key:query_args[key][0] for key in query_args}
            node_list = yield self.get_unique_queries(unique_stuff)
            unique_list = yield self.get_query_values(node_list)
            done = True
            message = {'nodes':unique_list}
            self.set_status(200)
        # get node list
        if not done and not node_uuid:
            message = yield self.get_node_list(account, start, end, lapse, status, page_num)
            message = {
                'count': node_list.get('response')['numFound'],
                'page': page_num,
                'results': []
            }
            for doc in node_list.get('response')['docs']:
                IGNORE_ME = ["_yz_id","_yz_rk","_yz_rt","_yz_rb"]
                message['results'].append(
                    dict((key.split('_register')[0], value) 
                    for (key, value) in doc.items() if key not in IGNORE_ME)
                )
            self.set_status(200)
        # single node received
        if not done and node_uuid:
            # try to get stuff from cache first
            node_uuid = node_uuid.rstrip('/')
            # get cache data
            message = self.cache.get('nodes:{0}'.format(node_uuid))
            if message is not None:
                logging.info('nodes:{0} done retrieving!'.format(node_uuid))
                #result = data
                self.set_status(200)
            else:
                #data = yield self.get_node(account, node_uuid.rstrip('/'))
                message = yield self.get_query(account, node_uuid)
                if self.cache.add('nodes:{0}'.format(node_uuid), message, 1):
                    logging.info('new cache entry {0}'.format(str(node_uuid)))
                    self.set_status(200)
            if not message:
                self.set_status(400)
                message = {'missing account {0} node_uuid {1} page_num {2} checked {3}'.format(
                    account, node_uuid.rstrip('/'), page_num, checked):result}
        # thanks for all the fish
        self.finish(message)

    @gen.coroutine
    def get(self, account=None, node_uuid=None, start=None, end=None, page_num=1, lapse='hours'):
        '''
            Get nodes
        '''
        # request query arguments
        query_args = self.request.arguments
        # get the current frontend logged username
        username = self.get_current_username()
        # if the user don't provide an account we use the username
        account = (query_args.get('account', [username])[0] if not account else account)
        # query string checked from string to boolean
        checked = str2bool(str(query_args.get('checked', [False])[0]))
        # getting pagination ready
        page_num = int(query_args.get('page', [page_num])[0])
        # not unique
        unique = query_args.get('unique', False)
        # rage against the finite state machine
        status = 'all'
        # are we done yet?
        done = False
        # some random that crash this shit
        message = {'crashing': True}
        # unique flag activated
        if unique:
            unique_stuff = {key:query_args[key][0] for key in query_args}
            node_list = yield self.get_unique_querys(unique_stuff)
            unique_list = yield self.get_query_values(node_list)
            done = True
            message = {'nodes':unique_list}
            self.set_status(200)

        # get node list
        if not done and not node_uuid:
            node_list = yield self.get_node_list(account, start, end, lapse, status, page_num)
            message = {
                'count': node_list.get('response')['numFound'],
                'page': page_num,
                'results': []
            }
            for doc in node_list.get('response')['docs']:
                IGNORE_ME = ["_yz_id","_yz_rk","_yz_rt","_yz_rb"]
                message['results'].append(
                    dict((key.split('_register') or ('_set')[0][1], value) 
                    for (key, value) in doc.items() if key not in IGNORE_ME)
                )
            self.set_status(200)
        # single node received
        if not done and node_uuid:
            # try to get stuff from cache first
            node_uuid = node_uuid.rstrip('/')
            # get cache data
            message = self.cache.get('nodes:{0}'.format(node_uuid))
            if message is not None:
                logging.info('nodes:{0} done retrieving!'.format(node_uuid))
                #result = data
                self.set_status(200)
            else:
                #data = yield self.get_node(account, node_uuid.rstrip('/'))
                message = yield self.get_node(account, node_uuid)
                if self.cache.add('nodes:{0}'.format(node_uuid), message, 1):
                    logging.info('new cache entry {0}'.format(str(node_uuid)))
                    self.set_status(200)
            if not message:
                self.set_status(400)
                message = {'missing account {0} node_uuid {1} page_num {2} checked {3}'.format(
                    account, node_uuid.rstrip('/'), page_num, checked):result}
        # thanks for all the fish
        self.finish(message)

    @gen.coroutine
    def post(self):
        '''
            Create node
        '''
        struct = yield check_json(self.request.body)
        format_pass = (True if struct and not struct.get('errors') else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return
        # request query arguments
        query_args = self.request.arguments
        # get account from new node struct
        account = struct.get('account', None)
        # get the current frontend logged username
        username = self.get_current_username()
        # if the user don't provide an account we use the username
        account = (query_args.get('account', [username])[0] if not account else account)
        # execute new node struct
        ack = yield self.new_node(struct)
        # complete message with receive acknowledgment uuid.
        message = {'uuid':ack}
        if 'error' in message['uuid']:
            scheme = 'node'
            reason = {'duplicates': [
                (scheme, 'account'),
                (scheme, 'uuid')
            ]}
            message = yield self.let_it_crash(struct, scheme, message['uuid'], reason)
            self.set_status(400)
        else:
            self.set_status(201)
        self.finish(message)

    @gen.coroutine
    def patch(self, node_uuid):
        '''
            Modify node
        '''
        struct = yield check_json(self.request.body)
        format_pass = (True if not dict(struct).get('errors', False) else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return
        account = self.request.arguments.get('account', [None])[0]
        if not account:
            # if not account we try to get the account from struct
            account = struct.get('account', None)
        result = yield self.modify_node(account, node_uuid, struct)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('node', node_uuid)
            self.finish(error)
            return
        self.set_status(200)
        self.finish({'message': 'update completed successfully'})

    @gen.coroutine
    def delete(self, node_uuid):
        '''
            Delete node
        '''
        query_args = self.request.arguments
        account = query_args.get('account', [None])[0]
        result = yield self.remove_node(account, node_uuid)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('node', node_uuid)
            self.finish(error)
            return
        self.set_status(204)
        self.finish()

    @gen.coroutine
    def options(self, node_uuid=None):
        '''
            Resource options
        '''
        self.set_header('Access-Control-Allow-Origin', '*')
        self.set_header('Access-Control-Allow-Methods', 'HEAD, GET, POST, PATCH, DELETE, OPTIONS')
        self.set_header('Access-Control-Allow-Headers', ''.join(('Accept-Language,',
                        'DNT,Keep-Alive,User-Agent,X-Requested-With,',
                        'If-Modified-Since,Cache-Control,Content-Type,',
                        'Content-Range,Range,Date,Etag')))
        # allowed http methods
        message = {
            'Allow': ['HEAD', 'GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS']
        }
        # resource parameters
        parameters = {}
        # mock your stuff
        stuff = models.Node.get_mock_object().to_primitive()
        for k, v in stuff.items():
            if v is None:
                parameters[k] = str(type('none'))
            elif isinstance(v, unicode):
                parameters[k] = str(type('unicode'))
            else:
                parameters[k] = str(type(v))
        # after automatic madness return description and parameters
        # we now have the option to clean a little bit.
        parameters['labels'] = 'array/string'
        # end of manual cleaning
        POST = {
            "description": "Send node",
            "parameters": parameters
        }
        # filter single resource
        if not node_uuid:
            message['POST'] = POST
        else:
            message['Allow'].remove('POST')
            message['Allow'].append('PATCH')
            message['Allow'].append('DELETE')
        self.set_status(200)
        self.finish(message)