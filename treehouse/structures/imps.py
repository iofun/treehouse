# -*- coding: utf-8 -*-
'''
    Treehouse CRDT unit structures.
'''

# This file is part of treehouse.

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
            Unit (IMP) map structure
        '''
        bucket = client.bucket_type(bucket_type).bucket('{0}'.format(bucket_name))
        bucket.set_properties({'search_index': search_index})
        self.map = Map(bucket, None)
        self.map.registers['uuid'].assign(struct.get('uuid', ''))
        self.map.registers['hash'].assign(struct.get('hash', ''))
        self.map.registers['image'].assign(struct.get('image', ''))
        self.map.registers['secret'].assign(struct.get('secret', ''))
        self.map.registers['config'].assign(struct.get('config', ''))
        self.map.registers['account'].assign(struct.get('account', ''))
        self.map.registers['model_uuid'].assign(struct.get('model_uuid', ''))
        self.map.registers['feature_uuid'].assign(struct.get('feature_uuid', ''))
        self.map.registers['status'].assign(struct.get('status', ''))
        self.map.registers['loss'].assign(struct.get('loss', ''))
        self.map.registers['gradients'].assign(struct.get('gradients', ''))
        self.map.registers['resources'].assign(struct.get('resources', ''))
        self.map.registers['labels'].assign(struct.get('labels', ''))
        self.map.registers['centers'].assign(struct.get('centers', ''))
        self.map.registers['unique_labels'].assign(struct.get('unique_labels', ''))
        self.map.registers['public'].assign(struct.get('public', ''))
        self.map.registers['checked'].assign(struct.get('checked', ''))
        self.map.registers['checked_by'].assign(struct.get('checked_by', ''))
        self.map.registers['created_at'].assign(struct.get('created_at', ''))
        self.map.registers['updated_by'].assign(struct.get('updated_by', ''))
        self.map.registers['updated_at'].assign(struct.get('updated_at', ''))
        self.map.registers['url'].assign(struct.get('url', ''))
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
            "uuid": event.registers['uuid'].value,
            "hash": event.registers['hash'].value,
            "image": event.registers['image'].value,
            "secret": event.registers['secret'].value,
            "config": event.registers['config'].value,
            "account": event.registers['account'].value,
            "model_uuid": event.registers['model_uuid'].value,
            "feature_uuid": event.registers['feature_uuid'].value,
            "status": event.registers['status'].value,
            "loss": event.registers['loss'].value,
            "gradients": event.registers['gradients'].value,
            "resources": event.registers['resources'].value,
            "labels": event.registers['labels'].value,
            "centers": event.registers['centers'].value,
            "unique_labels": event.registers['unique_labels'].value,
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
        struct = {
            "uuid": event.registers['uuid'].value,
            "hash": event.registers['hash'].value,
            "account": event.registers['account'].value,
            "model_uuid": event.registers['model_uuid'].value,
            "feature_uuid": event.registers['feature_uuid'].value,
            "status": event.registers['status'].value,
            "loss": event.registers['loss'].value,
            "gradients": event.registers['gradients'].value,
            "resources": event.registers['resources'].value,
            "labels": event.registers['labels'].value,
            "centers": event.registers['centers'].value,
            "unique_labels": event.registers['unique_labels'].value,
            "public": event.registers['public'].value,
            "checked": event.registers['checked'].value,
            "checked_by": event.registers['checked_by'].value,
            "created_at": event.registers['created_at'].value,
            "updated_by": event.registers['updated_by'].value,
            "updated_at": event.registers['updated_at'].value,
            "url": event.registers['url'].value,
        }
        return struct