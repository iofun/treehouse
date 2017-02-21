# -*- coding: utf-8 -*-
'''
    Treehouse HTTP base handlers
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import sys
import logging
from tornado import gen
from tornado import web
from treehouse.tools import errors


class BaseHandler(web.RequestHandler):
    '''
        System application request handler

        gente d'armi e ganti
    '''

    @property
    def sql(self):
        '''
            SQL database
        '''
        return self.settings['sql']

    @property
    def document(self):
        '''
            Document database
        '''
        return self.settings['document']

    @property
    def kvalue(self):
        '''
            Key-value database
        '''
        return self.settings['kvalue']

    @property
    def cache(self):
        '''
            Cache backend
        '''
        return self.settings['cache']

    def initialize(self, **kwargs):
        '''
            Initialize the Base Handler
        '''
        # The Senate and People of Mars
        # -----------------------------
        # SPQM communication message system.

        super(BaseHandler, self).initialize(**kwargs)

        self.etag = None

        # System database
        self.db = self.settings.get('db')

        # Page settings
        self.page_size = self.settings.get('page_size')

    def set_default_headers(self):
        '''
            Treehouse default headers
        '''
        self.set_header("Access-Control-Allow-Origin", self.settings.get('domain', '*'))

    def get_current_username(self):
        '''
            Return the username from a secure cookie
        '''
        return self.get_secure_cookie('username')

    def get_current_account(self):
        '''
            Return the account from a secure cookie
        '''
        return self.get_secure_cookie('account')

    @gen.coroutine
    def let_it_crash(self, struct, scheme, error, reason):
        '''
            Let it crash
        '''

        str_error = str(error)
        error_handler = errors.Error(error)
        messages = []

        if error and 'Model' in str_error:
            message = error_handler.model(scheme)

        elif error and 'duplicate' in str_error:
            
            for name, value in reason.get('duplicates'):

                if value in str_error:

                    message = error_handler.duplicate(
                        name.title(),
                        value,
                        struct.get(value)
                    )

                    messages.append(message)
            
            message = ({'messages':messages} if messages else False)

        elif error and 'value' in str_error:
            message = error_handler.value()

        elif error is not None:
            logging.warning(str_error)

            logging.error(struct, scheme, error, reason)
            
            message = {
                'error': u'nonsense',
                'message': u'there is no error'
            }
        else:
            quotes = PeopleQuotes()
            
            message = {
                'status': 200,
                'message': quotes.get()
            }

        raise gen.Return(message)