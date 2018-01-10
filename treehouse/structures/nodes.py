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
        self.map.registers['url'].assign(struct.get('url', ''))
        self.map.registers['labels'].assign(struct.get('labels'))
        self.map.registers['hashs'].assign(struct.get('hashs', ''))
        self.map.registers['resources'].assign(struct.get('resources', ''))
        self.map.registers['units'].assign(struct.get('units', ''))
        self.map.registers['history'].assign(struct.get('history', ''))
        self.map.registers['centers'].assign(struct.get('centers', ''))
        self.map.registers['resource'].assign(struct.get('resource', ''))
        self.map.registers['resource_uuid'].assign(struct.get('resource_uuid', ''))
        self.map.registers['active'].assign(struct.get('active', ''))
        self.map.registers['watchers'].assign(struct.get('watchers', ''))
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
            "url": event.registers['url'].value,
            "labels": event.registers['labels'].value,
            "hashs": event.registers['hashs'].value,
            "resources": event.registers['resources'].value,
            "units": event.registers['units'].value,
            "history": event.registers['history'].value,
            "centers": event.registers['centers'].value,
            "resource":event.registers['resource'].value,
            "resource_uuid":event.registers['resource_uuid'].value,
            "active":event.registers['active'].value,
            "watchers": event.registers['watchers'].value,
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
            "url": event.registers['url'].value,
            "labels": event.registers['labels'].value,
            "hashs": event.registers['hashs'].value,
            "resources": event.registers['resources'].value,
            "units": event.registers['units'].value,
            "history": event.registers['history'].value,
            "centers": event.registers['centers'].value,
            "resource":event.registers['resource'].value,
            "resource_uuid":event.registers['resource_uuid'].value,
            "active":event.registers['active'].value,
            "watchers": event.registers['watchers'].value,
        }
        return struct