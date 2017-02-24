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
        Treehouse unit (IMP)
    '''
    uuid
    hash
    account
    resources
    status
    loss
    gradients
    labels
    centers
    public
    checked
    checked_by
    created_at
    updatedt_by
    updatedt_at
    url


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
    uuid
    hash
    account
    resources
    status
    loss
    gradients
    labels
    centers
    public
    checked
    checked_by
    created_at
    updatedt_by
    updatedt_at
    url