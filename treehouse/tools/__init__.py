# -*- coding: utf-8 -*-
'''
    Treehouse system tool functions.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import time
import arrow
import ujson as json
import logging
from tornado import gen
from treehouse import errors


def get_average(total, marks):
    '''
        Get average from signals
    '''
    return float(total) / len(marks)

def get_percentage(part, whole):
    '''
        Get percentage of part and whole.

    '''
    return "{0:.0f}%".format(float(part)/whole * 100)

def socketid2hex(sid):
    '''
        Returns printable hex representation of a socket id.
    '''
    return ''.join("%02X" % ord(c) for c in sid)

def split_address(message):
    '''
        Function to split return Id and message received by ROUTER socket.

        Returns 2-tuple with return Id and remaining message parts.
        Empty frames after the Id are stripped.
    '''
    ret_ids = []
    for i, p in enumerate(message):
        if p:
            ret_ids.append(p)
        else:
            break
    return (ret_ids, message[i + 1:])

@gen.coroutine
def check_json(struct):
    '''
        Check for malformed JSON
    '''
    try:
        struct = json.loads(struct)
    except Exception, e:
        api_error = errors.Error(e)
        error = api_error.json()
        logging.exception(e)
        raise gen.Return(error)
        return
    raise gen.Return(struct)

@gen.coroutine
def check_times(start, end):
    '''
        Check times
    '''
    try:
        start = (arrow.get(start) if start else arrow.utcnow())
        end = (arrow.get(end) if end else start.replace(days=+1))
        start = start.timestamp
        end = end.timestamp
    except Exception, e:
        logging.exception(e)
        raise e
        return
    message = {'start':start, 'end':end}
    raise gen.Return(message)

@gen.coroutine
def check_times_get_timestamp(start, end):
    '''
        Check times
    '''
    try:
        start = (arrow.get(start) if start else arrow.utcnow())
        end = (arrow.get(end) if end else start.replace(days=+1))
    except Exception, e:
        logging.exception(e)
        raise e
        return
    message = {'start':start.timestamp, 'end':end.timestamp}
    raise gen.Return(message)

@gen.coroutine
def check_times_get_datetime(start, end):
    '''
        Check times
    '''
    try:
        start = (arrow.get(start) if start else arrow.utcnow())
        end = (arrow.get(end) if end else start.replace(days=+1))
    except Exception, e:
        logging.exception(e)
        raise e
        return
    message = {'start':start.naive, 'end':end.naive}
    raise gen.Return(message)

def clean_message(struct):
    '''
        clean message structure
    '''
    struct = struct.to_native()
    struct = {
        key: struct[key]
            for key in struct
                if struct[key] is not None
    }
    return struct

def clean_structure(struct):
    '''
        clean structure
    '''
    struct = struct.to_primitive()
    struct = {
        key: struct[key]
            for key in struct
                if struct[key] is not None
    }
    return struct

def clean_results(results):
    '''
        clean results
    '''
    results = results.to_primitive()
    results = results.get('results')
    results = [
        {
            key: dic[key]
                for key in dic
                    if dic[key] is not None
        } for dic in results
    ]
    return {'results': results}

def str2bool(boo):
    '''
        String to boolean
    '''
    return boo.lower() in ('yes', 'true', 't', '1')
