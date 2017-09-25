# -*- coding: utf-8 -*-
'''
    Treehouse CRDT node structures.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

import riak
import logging
import ujson as json
from riak.datatypes import Map

class NodeMap(object):

    def __init__(
        self,
        client,
        bucket_name,
        bucket_type,
        search_index,
        struct
    ):
        '''
            Node map structure
        '''
        bucket = client.bucket_type(bucket_type).bucket('{0}'.format(bucket_name))
        bucket.set_properties({'search_index': search_index})
        self.map = Map(bucket, None)
        self.map.registers['uuid'].assign(struct.get('uuid', ''))
        self.map.registers['account'].assign(struct.get('account', ''))
        self.map.registers['checked'].assign(struct.get('checked', ''))
        self.map.registers['status'].assign(struct.get('status', ''))
        self.map.registers['created_at'].assign(struct.get('created_at', ''))
        self.map.registers['created_by'].assign(struct.get('created_by', ''))
        self.map.registers['last_update_by'].assign(struct.get('last_update_by', ''))
        self.map.registers['last_update_at'].assign(struct.get('last_update_at', ''))
        self.map.registers['checksum'].assign(struct.get('checksum', ''))
        self.map.registers['name'].assign(struct.get('name', ''))
        self.map.registers['description'].assign(struct.get('description', ''))
        self.map.registers['region'].assign(struct.get('region', ''))
        self.map.registers['ranking'].assign(struct.get('ranking', ''))
        self.map.registers['public'].assign(struct.get('public', ''))
        self.map.registers['uri'].assign(struct.get('uri', ''))
        self.map.sets['labels'].add(struct.get('labels'))
        self.map.registers['hashs'].assign(struct.get('hashs', ''))
        self.map.registers['resources'].assign(struct.get('resources', ''))
        self.map.registers['units'].assign(struct.get('units', ''))
        self.map.registers['history'].assign(struct.get('history', ''))
        self.map.registers['centers'].assign(struct.get('centers', ''))
        self.map.counters['resources_total'].assign(struct.get('resources_total', ''))
        self.map.counters['units_total'].assign(struct.get('units_total', ''))
        self.map.counters['centers_total'].assign(struct.get('centers_total', ''))
        self.map.counters['history_total'].assign(struct.get('history_total', ''))
        self.map.counters['labels_total'].assign(struct.get('labels_total', ''))
        self.map.counters['hashs_total'].assign(struct.get('hashs_total', ''))
        self.map.store()

    @property
    def uuid(self):
        return self.map.reload().registers['uuid'].value

    @property
    def account(self):
        return self.map.reload().registers['account'].value

    def to_json(self):
        event = self.map.reload()
        struct = struct = {
            "uuid": event.registers['uuid'].value,
            "account": event.registers['account'].value,
            "checked": event.registers['checked'].value,
            "status": event.registers['status'].value,
            "created_at": event.registers['created_at'].value,
            "created_by": event.registers['created_by'].value,
            "last_update_by": event.registers['last_update_by'].value,
            "last_update_at": event.registers['last_update_at'].value,
            "checksum": event.registers['checksum'].value,
            "name": event.registers['name'].value,
            "description": event.registers['description'].value,
            "region": event.registers['region'].value,
            "ranking": event.registers['ranking'].value,
            "public": event.registers['public'].value,
            "uri": event.registers['uri'].value,
            "labels": event.sets['labels'].value,
            "hashs": event.registers['hashs'].value,
            "resources": event.registers['resources'].value,
            "units": event.registers['units'].value,
            "history": event.registers['history'].value,
            "centers": event.registers['centers'].value,
            "resources_total": event.counters['resources_total'].value,
            "units_total": event.counters['units_total'].value,
            "centers_total": event.counters['centers_total'].value,
            "history_total": event.counters['history_total'].value,
            "labels_total": event.counters['labels_total'].value,
            "hashs_total": event.counters['hashs_total'].value,
        }
        return json.dumps(struct)

    def to_dict(self):
        event = self.map.reload()
        struct = struct = {
            "uuid": event.registers['uuid'].value,
            "account": event.registers['account'].value,
            "checked": event.registers['checked'].value,
            "status": event.registers['status'].value,
            "created_at": event.registers['created_at'].value,
            "created_by": event.registers['created_by'].value,
            "last_update_by": event.registers['last_update_by'].value,
            "last_update_at": event.registers['last_update_at'].value,
            "checksum": event.registers['checksum'].value,
            "name": event.registers['name'].value,
            "description": event.registers['description'].value,
            "region": event.registers['region'].value,
            "ranking": event.registers['ranking'].value,
            "public": event.registers['public'].value,
            "uri": event.registers['uri'].value,
            "labels": event.sets['labels'].value,
            "hashs": event.registers['hashs'].value,
            "resources": event.registers['resources'].value,
            "units": event.registers['units'].value,
            "history": event.registers['history'].value,
            "centers": event.registers['centers'].value,
            "resources_total": event.counters['resources_total'].value,
            "units_total": event.counters['units_total'].value,
            "centers_total": event.counters['centers_total'].value,
            "history_total": event.counters['history_total'].value,
            "labels_total": event.counters['labels_total'].value,
            "hashs_total": event.counters['hashs_total'].value,
        }
        return struct