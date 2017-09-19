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
    checked = types.StringType(default=False)
    status = types.StringType()
    created_at = types.TimestampType(default=arrow.utcnow().timestamp)
    created_by = types.StringType()
    last_update_by = types.StringType()
    last_update_at = types.TimestampType(default=arrow.utcnow().timestamp)
    checksum = types.StringType()
    name = types.StringType()
    description = types.StringType()
    region = types.StringType()
    ranking = types.StringType()
    public = types.StringType()
    uri = types.StringType()
    centers = compound.ListType(types.StringType())
    labels = compound.ListType(types.StringType())
    hashs = compound.ListType(types.StringType())
    resources = compound.ListType(types.StringType())
    units = compound.ListType(types.StringType())
    history = compound.ListType(types.StringType())
    labels_total = types.IntType()
    hashs_total = types.IntType()

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
    centers = compound.ListType(types.StringType())
    created_at = types.TimestampType()
    created_by = types.StringType()
    last_update_by = types.StringType()
    last_update_at = types.TimestampType(default=arrow.utcnow().timestamp)
    checksum = types.StringType()
    name = types.StringType()
    description = types.StringType()
    region = types.StringType()
    ranking = types.StringType()
    public = types.StringType()
    checked = types.StringType()
    uri = types.StringType()
    labels = compound.ListType(types.StringType())
    hashs = compound.ListType(types.StringType())
    resources = compound.ListType(types.StringType())
    units = compound.ListType(types.StringType())
    history = compound.ListType(types.StringType())
    labels_total = types.IntType()
    hashs_total = types.IntType()