# -*- coding: utf-8 -*-
'''
    Treehouse Indexes system logic.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import arrow

import uuid

import logging

from tornado import gen

from treehouse.messages import indexes

from treehouse.tools import clean_structure, clean_results


class Index(object):
    '''
        Treehouse Indexes

        Mostly SOLR indexes
    '''

    @gen.coroutine
    def new_index(self, struct):
        '''
            New Index
        ''' 
        try:
            index = indexes.Index(struct)
            index.validate()
            index = clean_structure(index)
        except Exception, e:
            logging.error(e)
            raise e

        try:
            index_uuid = str(uuid.uuid4())

            query = "INSERT INTO indexes(uuid, name, type) VALUES ('{0}', '{1}', '{2}')".format(index_uuid, struct['name'], struct['index_type'])

            results = yield self.sql.query(query)

            message = results.items()

            logging.warning(message)

            results.free()
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(index_uuid)

    