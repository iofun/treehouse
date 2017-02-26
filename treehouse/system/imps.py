# -*- coding: utf-8 -*-
'''
    Treehouse imps system logic.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import arrow
import uuid
import logging
import ujson as json
from tornado import gen
from schematics.types import compound
from treehouse.messages import imps
from treehouse.messages import BaseResult
from treehouse.structures.imps import UnitMap
from riak.datatypes import Map
from treehouse.tools import clean_structure
from tornado import httpclient as _http_client


_http_client.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')
http_client = _http_client.AsyncHTTPClient()


class UnitsResult(BaseResult):
    '''
        List result
    '''
    results = compound.ListType(compound.ModelType(imps.Unit))


class Units(object):
    '''
        treehouse (IMP) units 
    '''

    @gen.coroutine
    def get_query_values(self, urls):
        '''
            Process grouped values from Solr
        '''
        message_box = []
        def handle_request(response):
            '''
                asynchronous
                Request Handler
            '''
            if response.error:
                logging.error(response.error)
            else:
                result = json.loads(response.body)
                content = {}
                options = []
                for stuff in result['grouped']:
                    content['value'] = stuff[0:-9]
                    for g in result['grouped'][stuff]['groups']:
                        options.append(g['groupValue'])
                    content['options'] = options
                # append the final content
                message_box.append(content)
        try:
            for url in urls:
                http_client.fetch(url,callback=handle_request)
            while True:
                # We're just trying to sleep, I don't know man.
                yield gen.sleep(0.0001)
                if len(message_box) == len(urls):
                    break
                # who fucking cares...
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(message_box)

    @gen.coroutine
    def get_unique_querys(self, struct):
        '''
            Get unique list from Solr
        '''
        search_index = 'tree_unit_index'
        query = 'uuid_register:*'
        filter_query = 'uuid_register:*'
        message_box = []
        if 'unique' in struct.keys():
            del struct['unique']
        try:
            if len(struct.keys()) == 1:
                for key in struct.keys():
                    field_list = key
                    group_field = key
                    params = {
                        'wt': 'json',
                        'q': query,
                        'fl': field_list,
                        'fq':filter_query,
                        'group':'true',
                        'group.field':group_field,
                    }
                    url = ''.join((
                        'https://api.cloudforest.ws/search/query/',
                        search_index,
                        '?wt=json&q=uuid_register:*&fl=',
                        key,
                        '_register&fq=uuid_register:*&group=true&group.field=',
                        key,
                        '_register'))
                    message_box.append(url)
            else:
                for key in struct.keys():
                    field_list = key
                    group_field = key
                    params = {
                        'wt': 'json',
                        'q': query,
                        'fl': field_list,
                        'fq':filter_query,
                        'group':'true',
                        'group.field':group_field,
                    }
                    url = ''.join((
                        'https://api.cloudforest.ws/search/query/',
                        search_index,
                        '?wt=json&q=uuid_register:*&fl=',
                        key,
                        '_register&fq=uuid_register:*&group=true&group.field=',
                        key,
                        '_register'))
                    message_box.append(url)
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(message_box)

    @gen.coroutine
    def get_imp(self, account, imp_uuid):
        '''
            Get query
        '''
        search_index = 'tree_unit_index'
        query = 'uuid_register:{0}'.format(imp_uuid)
        filter_query = 'account_register:{0}'.format(account)
        # build the url
        url = "https://api.cloudforest.ws/search/query/{0}?wt=json&q={1}&fq={2}".format(
            search_index, query, filter_query
        )
        got_response = []
        def handle_request(response):
            '''
                Request Async Handler
            '''
            if response.error:
                logging.error(response.error)
                got_response.append({'error':True, 'message': response.error})
            else:
                got_response.append(json.loads(response.body))
        try:
            http_client.fetch(
                url,
                callback=handle_request
            )
            while len(got_response) == 0:
                yield gen.sleep(0.0020) # don't be careless with the time.
            stuff = got_response[0]
            if stuff['response']['numFound']:
                response_doc = stuff['response']['docs'][0]
                IGNORE_ME = ["_yz_id","_yz_rk","_yz_rt","_yz_rb"]
                message = dict(
                    # key, value
                    (key.split('_register')[0], value) 
                    for (key, value) in response_doc.items()
                    if key not in IGNORE_ME
                )
            else:
                message = {'message': 'not found'}
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(message)

    @gen.coroutine
    def get_imp_list(self, account, start, end, lapse, status, page_num):
        '''
            Get imp list
        '''
        search_index = 'tree_unit_index'
        query = 'uuid_register:*'
        filter_query = 'account_register:{0}'.format(account)
        page_num = int(page_num)
        page_size = self.settings['page_size']
        url = "https://api.cloudforest.ws/search/query/{0}?wt=json&q={1}&fq={2}".format(
            search_index, query, filter_query
        )
        von_count = 0
        got_response = []
        def handle_request(response):
            '''
                Request Async Handler
            '''
            if response.error:
                logging.error(response.error)
                got_response.append({'error':True, 'message': response.error})
            else:
                got_response.append(json.loads(response.body))
        try:
            http_client.fetch(
                url,
                callback=handle_request
            )
            while len(got_response) == 0:
                yield gen.sleep(0.0020) # don't be careless with the time.
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(got_response[0])

    @gen.coroutine
    def new_imp(self, struct):
        '''
            New query event
        '''
        # currently we are changing this in two steps, first create de index with a structure file
        search_index = 'tree_unit_index'
        # on the riak database with riak-admin bucket-type create `bucket_type`
        # remember to activate it with riak-admin bucket-type activate
        bucket_type = 'tree_unit'
        # the bucket name can be dynamic
        bucket_name = 'units'
        try:
            event = imps.Unit(struct)
            event.validate()
            event = clean_structure(event)
        except Exception, e:
            raise e
        try:
            message = event.get('uuid')
            structure = {
                "uuid": str(event.get('uuid', str(uuid.uuid4()))),
                "hash": str(event.get('hash', '')),
                "account": str(event.get('account', 'pebkac')),
                "resources": str(event.get('resources', '')),
                "status": str(event.get('status', '')),
                "loss": str(event.get('loss', '')),
                "gradients": str(event.get('gradients', '')),
                "labels": str(event.get('labels', '')),
                "centers": str(event.get('centers', '')),
                "public": str(event.get('public', '')),
                "checked": str(event.get('checked', '')),
                "checked_by": str(event.get('checked_by', '')),
                "created_at": str(event.get('created_at', '')),
                "updated_by": str(event.get('updated_by', '')),
                "updated_at": str(event.get('updated_at', '')),
                "url": str(event.get('url', '')),
            }
            result = UnitMap(
                self.kvalue,
                bucket_name,
                bucket_type,
                search_index,
                structure
            )
        except Exception, e:
            logging.error(e)
            message = str(e)
        raise gen.Return(message)

    @gen.coroutine
    def modify_imp(self, account, imp_uuid, struct):
        '''
            Modify query
        '''
        # riak search index
        search_index = 'tree_unit_index'
        # riak bucket type
        bucket_type = 'tree_unit'
        # riak bucket name
        bucket_name = 'units'
        # solr query
        query = 'uuid_register:{0}'.format(imp_uuid.rstrip('/'))
        # filter query
        filter_query = 'account_register:{0}'.format(account)
        # search query url
        url = "https://api.cloudforest.ws/search/query/{0}?wt=json&q={1}&fq={2}".format(
            search_index, query, filter_query
        )
        # pretty please, ignore this list of fields from database.
        IGNORE_ME = ["_yz_id","_yz_rk","_yz_rt","_yz_rb","checked","keywords"]
        got_response = []
        update_complete = False
        def handle_request(response):
            '''
                Request Async Handler
            '''
            if response.error:
                logging.error(response.error)
                got_response.append({'error':True, 'message': response.error})
            else:
                got_response.append(json.loads(response.body))
        try:
            http_client.fetch(
                url,
                callback=handle_request
            )
            while len(got_response) == 0:
                # don't be careless with the time.
                yield gen.sleep(0.0010) 
            response_doc = got_response[0].get('response')['docs'][0]
            riak_key = str(response_doc['_yz_rk'])
            bucket = self.kvalue.bucket_type(bucket_type).bucket('{0}'.format(bucket_name))
            bucket.set_properties({'search_index': search_index})
            contact = Map(bucket, riak_key)
            for key in struct:
                if key not in IGNORE_ME:
                    contact.registers['{0}'.format(key)].assign(str(struct.get(key)))
            contact.update()
            update_complete = True
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(update_complete)

    @gen.coroutine
    def replace_imp(self, account, imp_uuid, struct):
        '''
            Replace imp
        '''
        pass

    @gen.coroutine
    def remove_imp(self, account, imp_uuid):
        '''
            Remove imp
        '''
        pass