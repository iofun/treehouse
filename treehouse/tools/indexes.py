# -*- coding: utf-8 -*-
'''
    Overlord database indexes.
'''

# This file is part of overlord.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'

import logging


def ensure_indexes(db):
    '''        
        ensure_indexes(db)
    '''
    pass

# TODO: missing indexes for sql databases (we're using postgresql)

# def ensure_indexes(document, kvalue):
#     '''
#         Ensure indexes function

#         This function create indexes on the system data storages.
#     '''
#     ensure_mongo_indexes(document)
#     ensure_riak_indexes(kvalue)

# def ensure_mongo_indexes(document):
#     '''        
#         Ensure indexes function
        
#         This function create the indexes on the MongoDB BSON database,
#         more about mongodb or BSON objects on the follow urls:
        
#         (BSON)
#         (MongoDB)

#         ensure_indexes(db)
#     '''
#     # db.queues.ensure_index([('name', 1)], unique=True)
#     #db.accounts.ensure_index([('account', 1)], unique=True)
#     #db.accounts.ensure_index([('email', 1)], unique=True)
    
#     #https://jira.mongodb.org/browse/SERVER-1068

#     #db.accounts.ensure_index([('routes.dst', 1),
#     #                          ('routes.channel',1), 
#     #                          ('routes.dchannel',1)], unique=True)

# def ensure_riak_indexes(kvalue):
#     '''
#         Ensure indexes function

#         This function create the indexes on the Riak kvalue database,
#         more about riak or kvalue storages on the follow urls:

#         (riak docs)
#         (wikipedia)

#         ensure_riak_indexes(kvalue)
#     '''
#     try:
#         kvalue.create_search_index('log-events')
#     except Exception, e:
#         logging.warning(e)
#     