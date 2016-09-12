# -*- coding: utf-8 -*-
'''
    Overlord nodes system logic.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import arrow

import uuid

import logging

from tornado import gen

from treehouse.messages import imps, nodes 

from treehouse.tools import clean_structure, clean_results, str2bool


@gen.coroutine
def check_exist(db, node_uuid):
    '''
        Check if a given nodes exist
    '''
    try:
        exist = yield db.nodes.find_one(
            {'uuid': node_uuid},
            {'uuid':1, '_id':0}
        )
        exist = (True if exist else False)

    except Exception, e:
        logging.error(e)
        raise e

    raise gen.Return(exist)


class Nodes(object):
    '''
        Overlord nodes
    '''

    @gen.coroutine
    def get_nodes_list(self, account, checked, page_num):
        '''
            Get nodes list
        '''
        page_num = int(page_num)
        page_size = self.settings.get('page_size')
        nodes_list = []

        find_query = {'account':account}

        if checked != 'all':
            find_query['checked'] = str2bool(str(checked))

        query = self.db.nodes.find(find_query, {'_id':0, 'resources.imps.contains':0}) # imps or nodes?
        q = query.sort([('_id', -1)]).skip(int(page_num) * page_size).limit(page_size)

        try:
            while (yield query.fetch_next):
                node = q.next_object()
                nodes_list.append(node)
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)

        finally:
            raise gen.Return(nodes_list)

    @gen.coroutine
    def get_node(self, account, node_uuid):
        '''
            Get node
        '''
        message = None
        try:
            result = yield self.db.nodes.find_one(
                {
                'account':account,
                'uuid':node_uuid},
                {'_id':0, 'resources.imps.contains':0} # resources.imps or nodes?
            )
            if result:
                node = nodes.Nodes(result)
                node.validate()
                message = clean_structure(node)
        except Exception, e:
            # e is for error
            logging.exception(e)
            raise e
        finally:
            raise gen.Return(message)
    
    @gen.coroutine
    def new_node(self, struct):
        '''
            New node
        '''
        try:
            node = nodes.Nodes(struct)
            node.validate()
            node = clean_structure(node)
        except Exception, e:
            logging.error(e)
            raise e

        try:
            result = yield self.db.nodes.insert(node)
            message = node.get('uuid')
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(message)

    @gen.coroutine
    def modify_nodes(self, account, node_uuid, struct):
        '''
            Modify nodes
        '''
        try:
            nodes = nodes.ModifyNodes(struct)
            nodes.validate()
            nodes = clean_structure(nodes)
        except Exception, e:
            logging.error(e)
            message = str(e)
            raise e

        try:
            result = yield self.db.nodes.update(
                {'account':account,
                 'uuid':node_uuid
                },
                {'$set':nodes}
            )
            logging.info(result)
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(bool(result.get('n')))

    @gen.coroutine
    def replace_nodes(self, account, node_uuid, struct):
        '''
            Replace nodes
        '''
        try:
            nodes = nodes.Nodes(struct)
            nodes.validate()
            nodes = clean_structure(nodes)
        except Exception, e:
            logging.error(e)
            raise e

        try:
            result = yield self.db.nodes.update(
                {'account':account,
                 'uuid':uuid.UUID(node_uuid)},
                {'$set':nodes}
            )
            logging.info(result)            
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(bool(result.get('n')))

    @gen.coroutine
    def remove_nodes(self, account, node_uuid):
        '''
            Remove nodes
        '''
        message = None
        try:
            message = yield self.db.nodes.remove(
                {'account':account, 'uuid':uuid.UUID(node_uuid)}
            )
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(bool(message.get('n')))

    @gen.coroutine
    def check_exist(self, node_uuid):
        '''
            Check if a given node exist
        '''
        try:
            exist = yield self.db.nodes.find_one(
                                {'uuid': node_uuid},
                                {'uuid':1,
                                 '_id':0})
            exist = (True if exist else False)

        except Exception, e:
            logging.error(e)
            raise e

        raise gen.Return(exist)