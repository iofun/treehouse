# -*- coding: utf-8 -*-
'''
    Treehouse system errors.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


class ConnectionNotReadyError(RuntimeError):
    '''
        Exception raised when attempting to use some Worker before the handshake took place.
    '''
    pass


class MissingHeartbeat(UserWarning):
    '''
        Exception raised when a heartbeat was not received on time.
    '''
    pass


class Error(object):
    '''
        Treehouse custom error class
    '''
    
    def __init__(self, error):
        self.error = str(error)
        self.message = None
        self.hint = None
        self.data = None
        self.code = None

    def json(self):
        '''
            JSON error
        '''
        self.message = 'Invalid JSON Object'
        self.data = self.error

        return {
            'message': self.message,
            'errors': self.data
        }

    def msgpack(self):
        '''
            msgpack error
        '''
        self.message = 'Invalid Binary Object'
        self.data = self.error

        return {
            'message': self.message,
            'errors': self.data
        }

    def value(self):
        '''
            Value error
        '''
        self.message = 'Value Error'
        self.data = self.error

        return {
            'message': self.message,
            'errors': self.data
        }

    def model(self, model_name):
        '''
            Error model dataset
            
            model_name: Model name of the dataset
        '''
        model_name = ''.join((model_name, ' resource'))
        self.message = self.error.split('-')[0].strip(' ').replace(
            'Model', model_name)
        self.data = ''.join(
            self.error.split('-')[1:]).replace(
            '  ', ' - ')

        return {
            'message': self.message,
            'errors': self.data
        }

    def missing(self, resource, name):
        '''
            Missing error
        '''
        self.message = 'Missing %s resource [\"%s\"].' % (resource, name)
        self.data = self.error
        
        return {
            'message': self.message,
            'errors': self.data
        }

    def invalid(self, resource, name):
        '''
            Invalid error
        '''
        self.message = 'Invalid %s resource [\"%s\"].' % (resource, name)
        self.data = self.error

        return {
            'message': self.message,
            'errors': self.data
        }

    def duplicate(self, resource, field, value):
        '''
            Duplicate error
        '''
        self.message = ''.join((
            resource, ' ',
            field, ' ["', value, '"] invalid or already taken.'
        ))
        self.data = self.error

        return {
            'message': self.message,
            'errors': self.data
        }
