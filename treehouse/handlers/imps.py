# -*- coding: utf-8 -*-
'''
    Treehouse HTTP IMP handlers.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import logging
import ujson as json
from tornado import gen, web
from treehouse import errors
from treehouse.system import imps
from treehouse.messages import imps as models
from treehouse.tools import str2bool, check_json, new_resource
from treehouse.handlers import BaseHandler


class Handler(imps.Units, BaseHandler):
    '''
        HTTP request handlers
    '''

    @gen.coroutine
    def head(self, account=None, imp_uuid=None, page_num=0):
        '''
            Head units
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
        # status ?! ... rage against the finite state machine
        status = 'all'
        # are we done yet?
        done = False
        # some random that crash this shit
        message = {'crashing': True}
        # unique flag activated
        if unique:
            unique_stuff = {key:query_args[key][0] for key in query_args}
            query_list = yield self.get_unique_querys(unique_stuff)
            unique_list = yield self.get_query_values(query_list)
            done = True
            message = {'units':unique_list}
            self.set_status(200)
        # get imp units
        if not done and not imp_uuid:
            unit_list = yield self.get_imp_list(account, start, end, lapse, status, page_num)
            message = {
                'count': unit_list.get('response')['numFound'],
                'page': page_num,
                'results': []
            }
            for doc in unit_list.get('response')['docs']:
                IGNORE_ME = ["_yz_id","_yz_rk","_yz_rt","_yz_rb"]
                message['results'].append(
                    dict((key.split('_register')[0], value) 
                    for (key, value) in doc.items() if key not in IGNORE_ME)
                )
            self.set_status(200)
        # single imp received
        if not done and imp_uuid:
            # try to get stuff from cache first
            imp_uuid = imp_uuid.rstrip('/')
            # get cache data
            message = self.cache.get('units:{0}'.format(imp_uuid))
            if message is not None:
                logging.info('units:{0} done retrieving from cache!'.format(imp_uuid))
                self.set_status(200)
            else:
                data = yield self.get_imp(account, imp_uuid)
                if self.cache.add('units:{0}'.format(imp_uuid), data, 1):
                    logging.info('new cache entry {0}'.format(str(imp_uuid)))
                    self.set_status(200)
            if not message:
                self.set_status(400)
                message = {'missing account {0} imp_uuid {1} page_num {2} checked {3}'.format(
                    account, imp_uuid, page_num, checked):message}
        # thanks for all the fish
        self.finish(message)

    @gen.coroutine
    def get(self, account=None, imp_uuid=None, page_num=0):
        '''
            Get imps
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
        # status ?! ... rage against the finite state machine
        status = 'all'
        # are we done yet?
        done = False
        # some random that crash this shit
        message = {'crashing': True}
        # unique flag activated
        if unique:
            unique_stuff = {key:query_args[key][0] for key in query_args}
            query_list = yield self.get_unique_querys(unique_stuff)
            unique_list = yield self.get_query_values(query_list)
            done = True
            message = {'units':unique_list}
            self.set_status(200)
        # get imp units
        if not done and not imp_uuid:
            unit_list = yield self.get_imp_list(account, start, end, lapse, status, page_num)
            message = {
                'count': unit_list.get('response')['numFound'],
                'page': page_num,
                'results': []
            }
            for doc in unit_list.get('response')['docs']:
                IGNORE_ME = ["_yz_id","_yz_rk","_yz_rt","_yz_rb"]
                message['results'].append(
                    dict((key.split('_register')[0], value) 
                    for (key, value) in doc.items() if key not in IGNORE_ME)
                )
            self.set_status(200)
        # single imp received
        if not done and imp_uuid:
            # try to get stuff from cache first
            imp_uuid = imp_uuid.rstrip('/')
            # get cache data
            message = self.cache.get('units:{0}'.format(imp_uuid))
            if message is not None:
                logging.info('units:{0} done retrieving from cache!'.format(imp_uuid))
                self.set_status(200)
            else:
                data = yield self.get_imp(account, imp_uuid)
                if self.cache.add('units:{0}'.format(imp_uuid), data, 1):
                    logging.info('new cache entry {0}'.format(str(imp_uuid)))
                    self.set_status(200)
            if not message:
                self.set_status(400)
                message = {'missing account {0} imp_uuid {1} page_num {2} checked {3}'.format(
                    account, imp_uuid, page_num, checked):message}
        # thanks for all the fish
        self.finish(message)

    @gen.coroutine
    def post(self):
        '''
            Create (IMP) unit
        '''
        struct = yield check_json(self.request.body)
        format_pass = (True if struct and not struct.get('errors') else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return
        # request query arguments
        query_args = self.request.arguments
        # get account from new unit struct
        account = struct.get('account', None)
        # get the current frontend logged username
        username = self.get_current_username()
        # if the user don't provide an account we use the frontend username as last resort
        account = (query_args.get('account', [username])[0] if not account else account)
        # execute new imp struct
        new_unit = yield self.new_imp(struct)
        if 'error' in new_unit:
            scheme = 'unit'
            reason = {'duplicates': [
                (scheme, 'account'),
                (scheme, 'uuid')
            ]}
            message = yield self.let_it_crash(struct, scheme, new_unit, reason)
            logging.warning(message)
            self.set_status(400)
            self.finish(message)
            return
        self.set_status(201)
        self.finish({'uuid':new_unit})

    @gen.coroutine
    def patch(self, imp_uuid):
        '''
            Modify unit
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
        result = yield self.modify_unit(account, imp_uuid, struct)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('unit', imp_uuid)
            self.finish(error)
            return
        self.set_status(200)
        self.finish({'message': 'update completed successfully'})

    @gen.coroutine
    def delete(self, imp_uuid):
        '''
            Delete unit
        '''
        account = query_args.get('account', [None])[0]
        logging.info('account {0} uuid {1}'.format(account, imp_uuid))
        result = yield self.remove_unit(account, imp_uuid)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('unit', imp_uuid)
            self.finish(error)
            return
        self.set_status(204)
        self.finish()

    @gen.coroutine
    def options(self, imp_uuid=None):
        '''
            Resource options
        '''
        self.set_header('Access-Control-Allow-Origin', '*')
        self.set_header('Access-Control-Allow-Methods', 'HEAD, GET, POST, PATCH, DELETE, OPTIONS')
        self.set_header('Access-Control-Allow-Headers', ''.join((
                        'DNT,Keep-Alive,User-Agent,X-Requested-With',
                        'If-Modified-Since,Cache-Control,Content-Type',
                        'Content-Range,Range,Date,Etag')))
        # allowed http methods
        message = {
            'Allow': ['HEAD', 'GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS']
        }
        # resource parameters
        parameters = {}
        # mock your stuff
        stuff = models.Unit.get_mock_object().to_primitive()
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
            "description": "Spawn unit",
            "parameters": parameters
        }
        # filter single resource
        if not imp_uuid:
            message['POST'] = POST
        else:
            message['Allow'].remove('POST')
            message['Allow'].append('PATCH')
            message['Allow'].append('DELETE')
        self.set_status(200)
        self.finish(message)