# -*- coding: utf-8 -*-
'''
    Treehouse node message models.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid as _uuid
from schematics import models
from schematics import types
from schematics.types import compound
from treehouse.messages import Resource


class Node(models.Model):
    '''
        Thanks for all the fish!
    '''
    uuid = types.UUIDType(default=_uuid.uuid4)
    hash = types.StringType()
    account = types.StringType(required=True)
    name = types.StringType(required=True)
    description = types.StringType()
    resources = compound.ModelType(Resource)
    labels = types.StringType()
    centers = types.StringType()
    status = types.StringType()
    public = types.StringType()
    checked = types.BooleanType(default=False)
    checked_by = types.StringType()
    created_at = types.StringType()
    updated_by = types.StringType()
    updated_at = types.StringType()
    url = types.StringType()


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
    hash = types.StringType()
    account = types.StringType()
    name = types.StringType()
    description = types.StringType()
    resources = compound.ModelType(Resource)
    labels = types.StringType()
    centers = types.StringType()
    status = types.StringType()
    public = types.StringType()
    checked = types.BooleanType()
    checked_by = types.StringType()
    created_at = types.StringType()
    updated_by = types.StringType()
    updated_at = types.StringType()
    url = types.StringType()