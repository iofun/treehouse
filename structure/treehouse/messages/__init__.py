# -*- coding: utf-8 -*-
'''
    Treehouse system models and messages.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


from schematics import models
from schematics import types
from schematics.types import compound


class BaseResult(models.Model):
    '''
        Base Result
    '''
    count = types.IntType()
    page = types.IntType()


class SimpleResource(models.Model):
    '''
        Simple Resource
    '''
    contains = compound.ListType(types.UUIDType())
    total = types.IntType()


class Resource(models.Model):
    ''' 
        Resource
    '''
    records = compound.ModelType(SimpleResource)
    total = types.IntType()