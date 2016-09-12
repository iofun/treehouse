# -*- coding: utf-8 -*-
'''
    Treehouse Imps message models.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import uuid

from schematics import models
from schematics import types


class Imp(models.Model):
    '''
        Treehouse Imp
    '''
    uuid = types.UUIDType(default=uuid.uuid4)
    account = types.StringType(required=True)
    number_type = types.IntType(required=False)
    
    first_name = types.StringType()
    last_name = types.StringType()
    
    phone_number = types.StringType(required=True)
    number_type = types.IntType()
    description = types.StringType()
    
    country = types.StringType()
    location = types.StringType()
    timezone = types.StringType()

    email = types.EmailType()
    address = types.StringType()
    city = types.StringType()
    state = types.StringType()
    zip_code = types.StringType()

    checked = types.BooleanType(default=False)
    do_not_disturb = types.BooleanType(default=False)

    has_directory = types.BooleanType(default=False)
    directory_uuid = types.UUIDType(required=False)


class ModifyImp(models.Model):
    '''
        Modify Imp

        This model is similar to Imp.

        It lacks of require and default values on it's fields.

        The reason of it existence is that we need to validate
        every input data that came from outside the system, with 
        this we prevent users from using PATCH to create fields 
        outside the scope of the resource.
    '''
    email = types.EmailType()
    first_name = types.StringType()
    last_name = types.StringType()
    country = types.StringType()
    address = types.StringType()
    city = types.StringType()
    state = types.StringType()
    zip_code = types.StringType()
    phone_number = types.StringType()
    checked = types.BooleanType()
    do_not_disturb = types.BooleanType()
    has_directory = types.BooleanType()
    directory_uuid = types.UUIDType()