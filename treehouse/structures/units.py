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
        self.map.registers['uuid'].add(struct.get('uuid', ''))
        self.map.registers['account'].add(struct.get('account', ''))
        self.map.registers['name'].add(struct.get('name', ''))
        self.map.registers['style'].add(struct.get('style', ''))
        self.map.registers['description'].add(struct.get('description', ''))
        self.map.registers['payload'].add(struct.get('payload', ''))
        self.map.registers['status'].add(struct.get('status', ''))
        self.map.registers['region'].add(struct.get('region', ''))
        self.map.registers['ranking'].add(struct.get('ranking', ''))
        self.map.registers['public'].add(struct.get('public', ''))
        self.map.registers['checksum'].add(struct.get('checksum', ''))
        self.map.registers['checked'].add(struct.get('checked', ''))
        self.map.registers['checked_by'].add(struct.get('checked_by', ''))
        self.map.registers['checked_at'].add(struct.get('checked_at', ''))
        self.map.registers['last_update_at'].add(struct.get('last_update_at', ''))
        self.map.registers['last_update_by'].add(struct.get('last_update_by', ''))
        self.map.registers['uri'].add(struct.get('uri', ''))
        self.map.registers['labels_set'].add(struct.get('labels_set', ''))
        self.map.registers['labels_total'].add(struct.get('labels_total', ''))
        self.map.registers['history'].add(struct.get('history', ''))
        self.map.registers['history_total'].add(struct.get('history_total', ''))
        self.map.registers['hashs'].add(struct.get('hashs', ''))
        self.map.registers['hashs_total'].add(struct.get('hashs_total', ''))
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
        "name":event.registers['name'].value,
        "style":event.registers['style'].value,
        "description":event.registers['description'].value,
        "payload":event.registers['payload'].value,
        "status":event.registers['status'].value,
        "region":event.registers['region'].value,
        "ranking":event.registers['ranking'].value,
        "public":event.registers['public'].value,
        "checksum":event.registers['checksum'].value,
        "checked":event.registers['checked'].value,
        "checked_by":event.registers['checked_by'].value,
        "checked_at":event.registers['checked_at'].value,
        "last_update_at":event.registers['last_update_at'].value,
        "last_update_by":event.registers['last_update_by'].value,
        "uri":event.registers['uri'].value,
        "labels_set":event.registers['labels_set'].value,
        "labels_total":event.registers['labels_total'].value,
        "history":event.registers['history'].value,
        "history_total":event.registers['history_total'].value,
        "hashs":event.registers['hashs'].value,
        "hashs_total":event.registers['hashs_total'].value,
        }
        return json.dumps(struct)

    def to_dict(self):
        event = self.map.reload()
        struct = {
        "uuid":event.registers['uuid'].value,
        "account":event.registers['account'].value,
        "name":event.registers['name'].value,
        "style":event.registers['style'].value,
        "description":event.registers['description'].value,
        "payload":event.registers['payload'].value,
        "status":event.registers['status'].value,
        "region":event.registers['region'].value,
        "ranking":event.registers['ranking'].value,
        "public":event.registers['public'].value,
        "checksum":event.registers['checksum'].value,
        "checked":event.registers['checked'].value,
        "checked_by":event.registers['checked_by'].value,
        "checked_at":event.registers['checked_at'].value,
        "last_update_at":event.registers['last_update_at'].value,
        "last_update_by":event.registers['last_update_by'].value,
        "uri":event.registers['uri'].value,
        "labels_set":event.registers['labels_set'].value,
        "labels_total":event.registers['labels_total'].value,
        "history":event.registers['history'].value,
        "history_total":event.registers['history_total'].value,
        "hashs":event.registers['hashs'].value,
        "hashs_total":event.registers['hashs_total'].value,
        }
        return struct