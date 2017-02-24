# -*- coding: utf-8 -*-
'''
    Treehouse index message models.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid

from schematics import models
from schematics import types


class Index(models.Model):
    '''
        Treehouse Imp
    '''
    uuid = types.UUIDType(default=uuid.uuid4)
    name = types.StringType(required=True)
    account = types.StringType(required=False)
    index_type = types.StringType(required=False)
    file = types.StringType()
    created_at = types.StringType()
    

class ModifyIndex(models.Model):
    '''
        Modify Index

        This model is similar to Index.

        It lacks of require and default values on it's fields.

        The reason of it existence is that we need to validate
        every input data that came from outside the system, with 
        this we prevent users from using PATCH to create fields 
        outside the scope of the resource.
    '''
    uuid = types.UUIDType(default=uuid.uuid4)
    name = types.StringType(required=True)
    account = types.StringType(required=False)
    index_type = types.StringType(required=False)
    file = types.StringType()
    created_at = types.StringType()