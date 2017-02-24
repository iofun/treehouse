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
        # start of map structure
        self.map.registers['uuid'].assign(struct.get('uuid', ''))
        self.map.registers['account'].assign(struct.get('account', ''))
        self.map.registers['units'].assign(struct.get('units', ''))
        self.map.registers['status'].assign(struct.get('status', ''))
        self.map.registers['labels'].assign(struct.get('labels', ''))
        self.map.registers['size'].assign(struct.get('size', ''))
        self.map.registers['stride'].assign(struct.get('stride', ''))
        self.map.registers['offset'].assign(struct.get('offset', ''))
        self.map.registers['storage'].assign(struct.get('storage', ''))
        self.map.registers['total'].assign(struct.get('total', ''))
        self.map.registers['public'].assign(struct.get('public', ''))
        self.map.registers['checked'].assign(struct.get('checked', ''))
        self.map.registers['checked_by'].assign(struct.get('checked_by', ''))
        self.map.registers['created_at'].assign(struct.get('created_at', ''))
        self.map.registers['updated_by'].assign(struct.get('updated_by', ''))
        self.map.registers['updated_at'].assign(struct.get('updated_at', ''))
        self.map.registers['url'].assign(struct.get('url', ''))
        # end of the map stuff
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
            "units": event.registers['units'].value,
            "status": event.registers['status'].value,
            "labels": event.registers['labels'].value,
            "size": event.registers['size'].value,
            "stride": event.registers['stride'].value,
            "offset": event.registers['offset'].value,
            "storage": event.registers['storage'].value,
            "total": event.registers['total'].value,
            "public": event.registers['public'].value,
            "checked": event.registers['checked'].value,
            "checked_by": event.registers['checked_by'].value,
            "created_at": event.registers['created_at'].value,
            "updated_by": event.registers['updated_by'].value,
            "updated_at": event.registers['updated_at'].value,
            "url": event.registers['url'].value,
        }
        return json.dumps(struct)

    def to_dict(self):
        event = self.map.reload()
        struct = struct = {
            "uuid": event.registers['uuid'].value,
            "account": event.registers['account'].value,
            "units": event.registers['units'].value,
            "status": event.registers['status'].value,
            "labels": event.registers['labels'].value,
            "size": event.registers['size'].value,
            "stride": event.registers['stride'].value,
            "offset": event.registers['offset'].value,
            "storage": event.registers['storage'].value,
            "total": event.registers['total'].value,
            "public": event.registers['public'].value,
            "checked": event.registers['checked'].value,
            "checked_by": event.registers['checked_by'].value,
            "created_at": event.registers['created_at'].value,
            "updated_by": event.registers['updated_by'].value,
            "updated_at": event.registers['updated_at'].value,
            "url": event.registers['url'].value,
        }
        return struct