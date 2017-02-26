# -*- coding: utf-8 -*-
'''
    Treehouse unit message models.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid as _uuid
from schematics import models
from schematics import types


class Unit(models.Model):
    '''
        Jungle IMP's
    '''
    uuid = types.UUIDType(default=_uuid.uuid4)
    hash = types.StringType()
    image = types.StringType()
    address = types.StringType()
    config = types.StringType()
    secret = types.StringType()
    account = types.StringType(required=True)
    resources = types.StringType()
    status = types.StringType()
    loss = types.StringType()
    gradients = types.StringType()
    labels = types.StringType()
    centers = types.StringType()
    public = types.StringType()
    checked = types.StringType()
    checked_by = types.StringType()
    created_at = types.StringType()
    updated_by = types.StringType()
    updated_at = types.StringType()
    url = types.StringType()


class ModifyUnit(models.Model):
    '''
        Modify unit

        This model is similar to Unit.

        It lacks of require and default values on it's fields.

        The reason of it existence is that we need to validate
        every input data that came from outside the system, with 
        this we prevent users from using PATCH to create fields 
        outside the scope of the resource.
    '''
    uuid = types.UUIDType()
    hash = types.StringType()
    image = types.StringType()
    address = types.StringType()
    config = types.StringType()
    secret = types.StringType()
    account = types.StringType()
    resources = types.StringType()
    status = types.StringType()
    loss = types.StringType()
    gradients = types.StringType()
    labels = types.StringType()
    centers = types.StringType()
    public = types.StringType()
    checked = types.StringType()
    checked_by = types.StringType()
    created_at = types.StringType()
    updatedt_by = types.StringType()
    updatedt_at = types.StringType()
    url = types.StringType()