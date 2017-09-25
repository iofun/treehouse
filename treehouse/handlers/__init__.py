# -*- coding: utf-8 -*-
'''
    HTTP base handlers.
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
        Gente d'armi e ganti
    '''

    @property
    def sql(self):
        '''
            SQL database
        '''
        return self.settings['sql']

    @property
    def kvalue(self):
        '''
            Key-value database
        '''
        return self.settings['kvalue']

    @property
    def cache(self):
        '''
            #Cache backend
        '''
        return self.settings['cache']

    def initialize(self, **kwargs):
        '''
            Initialize the Base Handler
        '''
        # The Senate and People of Mars
        super(BaseHandler, self).initialize(**kwargs)
        # etag
        self.etag = None
        # System database
        self.db = self.settings.get('db')
        # System cache
        self.cache = self.settings.get('cache')
        # Page settings
        self.page_size = self.settings.get('page_size')
        # solr riak
        self.solr = self.settings.get('solr')

    def set_default_headers(self):
        '''
            Set default headers
        '''
        self.set_header("Access-Control-Allow-Origin", self.settings.get('domain', '*'))

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