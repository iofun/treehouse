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
# treehouse system imps
from treehouse.system import imps
# errors, string to boolean, check JSON, new resource
from treehouse.tools import errors, str2bool, check_json, new_resource
# system base handler
from treehouse.handlers import BaseHandler


@content_type_validation
class Handler(imps.Imps, BaseHandler):
    '''
        Imp HTTP request handlers
    '''

    @gen.coroutine
    def head(self, account=None, imp_uuid=None, page_num=0):
        '''
            Head Imps
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
        if not imp_uuid:
            # get list of imps
            imps = yield self.get_imp_list(account, checked, page_num)
            self.set_status(200)
            self.finish({'imps':imps})
        else:
            # try to get stuff from cache first
            logging.info('Getting imps:{0} from cache'.format(imp_uuid))
            data = self.cache.get('imps:{0}'.format(imp_uuid))
            if data is not None:
                logging.info('imps:{0} done retrieving!'.format(imp_uuid))
                result = data
            else:
                data = yield self.get_imp(account, imp_uuid)
                if self.cache.add('imps:{0}'.format(imp_uuid), data, 1):
                    logging.info('new cache entry {0}'.format(str(data)))
                    result = data
            if not result:
                self.set_status(400)
                self.finish({'missing':account})
            else:
                self.set_status(200)
                self.finish(result)

    @gen.coroutine
    def get(self, account=None, imp_uuid=None, page_num=0):
        '''
            Get imps
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
        if not imp_uuid:
            # get list of directories
            imps = yield self.get_imp_list(account, checked, page_num)
            self.set_status(200)
            self.finish({'imps':imps})
        else:
            # try to get stuff from cache first
            logging.info('imp_uuid {0}'.format(imp_uuid.rstrip('/')))
            data = self.cache.get('imps:{0}'.format(imp_uuid))
            if data is not None:
                logging.info('imps:{0} done retrieving!'.format(imp_uuid))
                result = data
            else:
                data = yield self.get_imp(account, imp_uuid.rstrip('/'))
                if self.cache.add('imps:{0}'.format(imp_uuid), data, 1):
                    logging.info('new cache entry {0}'.format(str(data)))
                    result = data
            if not result:
                self.set_status(400)
                self.finish({'missing account {0} imp_uuid {1} page_num {2} checked {3}'.format(
                    account, imp_uuid.rstrip('/'), page_num, checked):result})
            else:
                self.set_status(200)
                self.finish(result)

    @gen.coroutine
    def post(self):
        '''
            Create imp
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
        # logging new imp structure
        logging.info('new imp structure {0}'.format(str(struct)))
        # logging request query arguments
        logging.info(self.request.arguments)
        # request query arguments
        query_args = self.request.arguments
        # get account from new imp struct
        account = struct.get('account', None)
        # get the current frontend logged username
        username = self.get_current_username()
        # if the user don't provide an account we use the frontend username as last resort
        account = (query_args.get('account', [username])[0] if not account else account)
        # we use the front-end username as last resort
        if not struct.get('account'):
            struct['account'] = account
        logging.warning(account)
        #if 'directory_uuid' in struct:
        #    struct['has_directory'] = yield check_dir_exist(
        #        db,
        #        struct.get('directory_uuid')
        #    )
        new_imp = yield self.new_imp(struct)
        if 'error' in new_imp:
            scheme = 'imp'
            reason = {'duplicates': [
                (scheme, 'account'),
                (scheme, 'phone_number')
            ]}
            message = yield self.let_it_crash(struct, scheme, new_imp, reason)
            logging.warning(message)
            self.set_status(400)
            self.finish(message)
            return
        if struct.get('has_directory'):
            resource = {
                'directory': struct.get('directory_uuid'),
                'resource': 'imps',
                'uuid': new_imp
            }
            update = yield new_resource(db, resource, 'directories', 'directory')
            logging.info('update {0}'.format(update))
        self.set_status(201)
        self.finish({'uuid':new_imp})

    @gen.coroutine
    def patch(self, imp_uuid):
        '''
            Modify imp
        '''
        logging.info('request.arguments {0}'.format(self.request.arguments))
        logging.info('request.body {0}'.format(self.request.body))
        struct = yield check_json(self.request.body)
        logging.info('patch received struct {0}'.format(struct))
        format_pass = (True if not dict(struct).get('errors', False) else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return
        account = self.request.arguments.get('account', [None])[0]
        result = yield self.modify_imp(account, imp_uuid, struct)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('imp', imp_uuid)
            self.finish(error)
            return
        self.set_status(200)
        self.finish({'message': 'update completed successfully'})

    @gen.coroutine
    def put(self, imp_uuid):
        '''
            Replace imp
        '''
        logging.info('request.arguments {0}'.format(self.request.arguments))
        logging.info('request.body {0}'.format(self.request.body))
        struct = yield check_json(self.request.body)
        logging.info('put received struct {0}'.format(struct))
        format_pass = (True if not struct.get('errors') else False)
        if not format_pass:
            self.set_status(400)
            self.finish({'JSON':format_pass})
            return
        account = self.request.arguments.get('account', [None])[0]
        result = yield self.replace_imp(account, imp_uuid, struct)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('imp', imp_uuid)
            self.finish(error)
            return
        self.set_status(200)
        self.finish({'message': 'replace completed successfully'})

    @gen.coroutine
    def delete(self, imp_uuid):
        '''
            Delete imp
        '''
        logging.info(self.request.arguments)
        query_args = self.request.arguments
        account = query_args.get('account', [None])[0]
        logging.info('account {0} uuid {1}'.format(account, imp_uuid))
        result = yield self.remove_imp(account, imp_uuid)
        if not result:
            self.set_status(400)
            system_error = errors.Error('missing')
            error = system_error.missing('imp', imp_uuid)
            self.finish(error)
            return
        self.set_status(204)
        self.finish()

    @gen.coroutine
    def options(self, imp_uuid=None):
        '''
            Resource options
        '''
        self.set_header('Allow', 'HEAD, GET, POST, PATCH, PUT, DELETE, OPTIONS')
        self.set_status(200)
        message = {
            'Allow': ['HEAD', 'GET', 'POST', 'OPTIONS']
        }
        # return resource documentation examples?
        POST = {
            "POST": {
                "description": "Create Imp",
                "parameters": {

                    "email": {
                        "type": "string",
                        "description": "Email",
                        "required": False
                    },

                    "phone_number": {
                        "type": "string",
                        "description": "Phone number",
                        "required": True
                    },

                    "first_name": {
                        "type": "string",
                        "description": "First name",
                        "required": True
                    },
                
                    "last_name": {
                        "type": "string",
                        "description": "Last name",
                    },
                    "country": {
                        "type": "string",
                        "description": "Country"
                    },
                    "city": {
                        "type": "string",
                        "description": "City"
                    },
                    "state": {
                        "type": "string",
                        "description": "State"
                    },
                    "zip_code": {
                        "type": "string",
                        "description": "Zip code"
                    },
                    "labels": {
                        "type": "array/string",
                        "description": "Labels to associate with this task."
                    }
                },

                "example": {
                    "title": "Found a error, bug, inconsistency, your system is under attack.",
                    "body": "I'm having a problem with this.",
                    "assignee": "cebus",
                    "alert": 1,
                    "labels": [
                        "Imps are under attack",
                        "Imps are been eaten by random tird party."
                    ]
                }
            }
        }
        if not imp_uuid:
            message['POST'] = POST
        else:
            message['Allow'].remove('POST')
            message['Allow'].append('PUT')
            message['Allow'].append('PATCH')
            message['Allow'].append('DELETE')

        self.finish(message)