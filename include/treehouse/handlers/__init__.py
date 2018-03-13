# -*- coding: utf-8 -*-
'''
    HTTP base handlers.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


from tornado import web


class BaseHandler(web.RequestHandler):
    '''
        gente d'armi e ganti
    '''
    @property
    def kvalue(self):
        '''
            Key-value database
        '''
        return self.settings['kvalue']

    def initialize(self, **kwargs):
        '''
            Initialize the Base Handler
        '''
        super(BaseHandler, self).initialize(**kwargs)
        # System database
        self.db = self.settings.get('db')
        # System cache
        self.cache = self.settings.get('cache')
        # Page settings
        self.page_size = self.settings.get('page_size')
        # solr riak
        self.solr = self.settings.get('solr')
        # application domain
        self.domain = self.settings.get('domain')

    def set_default_headers(self):
        '''
            default headers
        '''
        self.set_header("Access-Control-Allow-Origin", self.settings.get('domain', '*'))