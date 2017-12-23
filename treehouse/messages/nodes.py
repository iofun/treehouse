# -*- coding: utf-8 -*-
'''
    Treehouse node message models.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid
import arrow
from schematics import models
from schematics import types
from schematics.types import compound
from treehouse.messages import Resource


class Node(models.Model):
    '''
        Thanks for all the fish!
    '''
    uuid = types.UUIDType(default=uuid.uuid4)
    account = types.StringType(required=True)
    status = types.StringType()
    public = types.StringType()
    name = types.StringType()
    description = types.StringType()
    checksum = types.StringType()
    region = types.StringType()
    ranking = types.StringType()
    url = types.URLType()
    labels = compound.ListType(types.StringType())
    hashs = compound.ListType(types.StringType())
    units = compound.ListType(types.StringType())
    resources = compound.ListType(types.StringType())
    centers = compound.ListType(types.StringType())
    history = compound.ListType(types.StringType())
    checked = types.BooleanType(default=False)
    checked_by = types.StringType()
    checked_at = types.TimestampType(default=arrow.utcnow().timestamp)
    created_by = types.StringType()
    created_at = types.TimestampType(default=arrow.utcnow().timestamp)
    last_update_by = types.StringType()
    last_update_at = types.TimestampType(default=arrow.utcnow().timestamp)
    resource = types.StringType()
    resource_uuid = types.StringType()
    active = types.BooleanType(default=True)


class ModifyNode(models.Model):
    '''
        Modify node

        This model is similar to node.

        It lacks of require and default values on it's fields.

        The reason of it existence is that we need to validate
        every input data that came from outside the system, with 
        this we prevent users from using PATCH to create fields 
        outside the scope of the resource.
    '''
    uuid = types.UUIDType()
    account = types.StringType()
    status = types.StringType()
    public = types.StringType()
    name = types.StringType()
    description = types.StringType()
    checksum = types.StringType()
    region = types.StringType()
    ranking = types.StringType()
    url = types.StringType()
    labels = compound.ListType(types.StringType())
    hashs = compound.ListType(types.StringType())
    units = compound.ListType(types.StringType())
    resources = compound.ListType(types.StringType())
    centers = compound.ListType(types.StringType())
    history = compound.ListType(types.StringType())
    checked = types.BooleanType(default=False)
    checked_by = types.StringType()
    checked_at = types.TimestampType(default=arrow.utcnow().timestamp)
    created_by = types.StringType()
    created_at = types.TimestampType()
    last_update_by = types.StringType()
    last_update_at = types.TimestampType(default=arrow.utcnow().timestamp)
    resource = types.StringType()
    resource_uuid = types.StringType()
    active = types.BooleanType()