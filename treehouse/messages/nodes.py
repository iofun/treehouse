# -*- coding: utf-8 -*-
'''
    Overlord node message models.
'''

# This file is part of overlord.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import uuid

from schematics import models
from schematics import types
from schematics.types import compound

from overlord.messages import Resource


class Node(models.Model):
    uuid = types.UUIDType(default=uuid.uuid4)
    account = types.StringType(required=True)
    name = types.StringType(required=True)
    description = types.StringType()
    checked = types.BooleanType(default=False)

    # -- resources
    resources = compound.ModelType(Resource)


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
    name = types.StringType()
    description = types.StringType()
    checked = types.BooleanType()