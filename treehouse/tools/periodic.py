# -*- coding: utf-8 -*-
'''
    Treehouse periodic system tools.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'



import logging
import ujson as json
from tornado import gen
from tornado import httpclient


httpclient.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')
