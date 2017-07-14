# -*- coding: utf-8 -*-
'''
    Treehouse tools system periodic functions.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import logging
from tornado import httpclient
import ujson as json
import uuid

from tornado import gen


httpclient.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')


# The Devil Went Down To Georgia - async functions/coroutines go down here: