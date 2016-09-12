# -*- coding: utf-8 -*-
'''
    Treehouse HTTP node handlers.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import ujson as json

from tornado import gen, web

import logging

from treehouse.system import nodes

from treehouse.tools import content_type_validation
from treehouse.tools import str2bool, check_json

from treehouse.tools import errors

from treehouse.handlers import BaseHandler


@content_type_validation
class Handler(nodes.Nodes, BaseHandler):
    '''
        nodes HTTP request handlers
    '''

    @gen.coroutine
    def head(self, account=None, node_uuid=None, page_num=0):
        '''
            Head nodes
        '''
        # logging request query arguments
        logging.info('request query arguments {0}'.format(self.request.arguments))

        # request query arguments
        query_args = self.request.arguments

        # get the current frontend logged username
        username = self.get_current_username()

        # if the user don't provide an account we use the frontend username as last resort
        account = (query_args.get('account', [username])[0] if not account else account)

        # query string checked from string to boolean
        checked = str2bool(str(query_args.get('checked', [False])[0]))

        if not node_uuid:
            # get list of nodes
            nodes = yield self.get_node_list(account, checked, page_num)
            self.set_status(200)
            self.finish({'nodes':nodes})
        else:
            # try to get stuff from cache first
            logging.info('node_uuid {0}'.format(node_uuid.rstrip('/')))
            
            data = self.cache.get('nodes:{0}'.format(node_uuid))

            if data is not None:
                logging.info('nodes:{0} done retrieving!'.format(node_uuid))
                result = data
            else:
                data = yield self.get_node(account, node_uuid.rstrip('/'))
                if self.cache.add('nodes:{0}'.format(node_uuid), data, 1):
                    logging.info('new cache entry {0}'.format(str(data)))
                    result = data


            # result = yield self.get_node(account, node_uuid)
  
            if not result:

                # -- need more info

                self.set_status(400)
                
                # -- why missing account?
                self.finish({'missing':account})
            else:
                self.set_status(200)
                self.finish(result)

    @gen.coroutine
    def get(self, account=None, node_uuid=None, page_num=0):
        '''
            Get nodes
        '''
        # logging request query arguments
        logging.info('request query arguments {0}'.format(self.request.arguments))

        # request query arguments
        query_args = self.request.arguments

        # get the current frontend logged username
        username = self.get_current_username()

        # if the user don't provide an account we use the frontend username as last resort
        account = (query_args.get('account', [username])[0] if not account else account)

        # query string checked from string to boolean
        checked = query_args.get('checked', [False])[0]

        logging.warning(checked)

        testc = str2bool(str(checked))

        logging.warning(testc)

        if not node_uuid:
            # get list of nodes
            nodes = yield self.get_node_list(account, checked, page_num)
            self.set_status(200)
            self.finish({'nodes':nodes})
        else:
            #account = account.rstrip('/')
            logging.info('node_uuid {0}'.format(node_uuid.rstrip('/')))
            result = yield self.get_node(account, node_uuid.rstrip('/'))

            if not result:
                
                # -- need to clean this info

                self.set_status(400)
                self.finish({'missing account {0} node_uuid {1} page_num {2} checked {3}'.format(
                    account, node_uuid.rstrip('/'), page_num, checked):result})
            else:
                self.set_status(200)
                self.finish(result)

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

        logging.info('new node structure {0}'.format(str(struct)))

        new_node = yield self.new_node(struct)
        
        if 'error' in new_node:
            model = 'node'
            reason = {'duplicates': [(model, 'account')]}

            message = yield self.let_it_crash(struct, model, new_node, reason)

            logging.warning(message)

            self.set_status(400)
            self.finish(message)
            return

        self.set_status(201)
        self.finish({'uuid':new_node})

    @gen.coroutine
    def patch(self, node_uuid):
        '''
            Modify node
        '''
        logging.info('request.arguments {0}'.format(self.request.arguments))
        logging.info('request.body {0}'.format(self.request.body))

        struct = yield check_json(self.request.body)

        logging.info('patch receive struct {0}'.format(struct))

        format_pass = (True if not dict(struct).get('errors', False) else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return

        account = self.request.arguments.get('account', [None])[0]

        result = yield self.modify_node(account, node_uuid.rstrip('/'), struct)

        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error= system_error.missing('node', node_uuid)
            self.finish(error)
            return

        self.set_status(200)
        self.finish({'message': 'update completed successfully'})

    @gen.coroutine
    def put(self, node_uuid):
        '''
            Replace node
        '''
        logging.info('request.argumens {0}'.format(self.request.arguments))
        logging.info('request.body {0}'.format(self.request.body))

        struct = yield check_json(self.request.body)

        logging.info('put receive struct {0}'.format(struct))

        format_pass = (True if not struct.get('errors') else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return

        account = self.request.arguments.get('account', [None])[0]

        result = yield self.replace_node(account, node_uuid, struct)

        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('node', node_uuid)
            self.finish(error)
            return

        self.set_status(200)
        self.finish({'message': 'replace completed successfully'})

    @gen.coroutine
    def delete(self, node_uuid):
        '''
            Delete node
        '''
        logging.info(self.request.arguments)

        query_args = self.request.arguments

        account = query_args.get('account', [None])[0]

        logging.info('account {0} uuid {1}'.format(account, node_uuid))
        
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
        self.set_header('Allow', 'HEAD, GET, POST, PATCH, PUT, DELETE, OPTIONS')
        self.set_status(200)

        message = {
            'Allow': ['HEAD', 'GET', 'POST', 'OPTIONS']
        }
        if not node_uuid:
            #message['POST'] = POST
            pass
        else:
            message['Allow'].remove('POST')
            message['Allow'].append('PUT')
            message['Allow'].append('PATCH')
            message['Allow'].append('DELETE')

        self.finish(message)