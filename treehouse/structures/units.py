# -*- coding: utf-8 -*-
'''
    Unit CRDT's structures.
'''

# This file is part of aqueduct.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

import riak
import logging
import ujson as json
from riak.datatypes import Map


class UnitMap(object):

    def __init__(
        self,
        client,
        bucket_name,
        bucket_type,
        search_index,
        struct
    ):
        '''
            Unit structure map.
        '''
        bucket = client.bucket_type(bucket_type).bucket('{0}'.format(bucket_name))
        bucket.set_properties({'search_index': search_index})
        self.map = Map(bucket, None)
        self.map.registers['uuid'].assign(struct.get('uuid', ''))
        self.map.registers['account'].assign(struct.get('account', ''))
        self.map.registers['source'].assign(struct.get('source', ''))
        self.map.registers['comment'].assign(struct.get('comment', ''))
        self.map.registers['resource'].assign(struct.get('resource', ''))
        self.map.registers['sentiment'].assign(struct.get('sentiment', ''))
        self.map.registers['ranking'].assign(struct.get('ranking', ''))
        self.map.registers['created_by'].assign(struct.get('created_by', ''))
        self.map.registers['created_at'].assign(struct.get('created_at', ''))
        self.map.registers['last_update_by'].assign(struct.get('last_update_by', ''))
        self.map.registers['last_update_at'].assign(struct.get('last_update_at', ''))
        self.map.registers['history'].assign(struct.get('history', ''))
        self.map.registers['labels'].assign(struct.get('labels', ''))
        self.map.registers['status'].assign(struct.get('status', ''))
        self.map.registers['resource_uuid'].assign(struct.get('resource_uuid', ''))
        self.map.store()

    @property
    def uuid(self):
        return self.map.reload().registers['uuid'].value

    @property
    def account(self):
        return self.map.reload().registers['account'].value

    def to_json(self):
        event = self.map.reload()
        struct = {
            "uuid":event.registers['uuid'].value,
            "account":event.registers['account'].value,
            "source":event.registers['source'].value,
            "comment":event.registers['comment'].value,
            "resource":event.registers['resource'].value,
            "sentiment":event.registers['sentiment'].value,
            "ranking":event.registers['ranking'].value,
            "created_by":event.registers['created_by'].value,
            "created_at":event.registers['created_at'].value,
            "last_update_by":event.registers['last_update_by'].value,
            "last_update_at":event.registers['last_update_at'].value,
            "history":event.registers['history'].value,
            "labels":event.registers['labels'].value,
            "status":event.registers['status'].value,
            "resource_uuid":event.registers['resource_uuid'].value,
        }
        return json.dumps(struct)

    def to_dict(self):
        event = self.map.reload()
        struct = {
            "uuid":event.registers['uuid'].value,
            "account":event.registers['account'].value,
            "source":event.registers['source'].value,
            "comment":event.registers['comment'].value,
            "resource":event.registers['resource'].value,
            "sentiment":event.registers['sentiment'].value,
            "ranking":event.registers['ranking'].value,
            "created_by":event.registers['created_by'].value,
            "created_at":event.registers['created_at'].value,
            "last_update_by":event.registers['last_update_by'].value,
            "last_update_at":event.registers['last_update_at'].value,
            "history":event.registers['history'].value,
            "labels":event.registers['labels'].value,
            "status":event.registers['status'].value,
            "resource_uuid":event.registers['resource_uuid'].value,
        }
        return struct