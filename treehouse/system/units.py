# -*- coding: utf-8 -*-
'''
    Cas units system logic.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

import arrow
import uuid
import urllib
import logging
import ujson as json
from tornado import gen
from schematics.types import compound
from treehouse.messages import units
from treehouse.messages import BaseResult
from treehouse.structures.units import UnitMap
from riak.datatypes import Map
from treehouse.tools import clean_structure, clean_results
from tornado.httputil import url_concat
from tornado import httpclient as _http_client


_http_client.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')
http_client = _http_client.AsyncHTTPClient()


class UnitResult(BaseResult):
    '''
        List result
    '''
    results = compound.ListType(compound.ModelType(units.Unit))


class Unit(object):
    '''
        Unit
    '''
    @gen.coroutine
    def get_query_values(self, urls):
        '''
            Process grouped values from Solr
        '''
        process_list = []
        def handle_request(response):
            '''
                Request Async Handler
            '''
            if response.error:
                logging.error(response.error)
            else:
                result = json.loads(response.body)
                content = {}
                options = []
                # gunter grass penguin powers
                for stuff in result['grouped']:
                    content['value'] = stuff[0:-9]
                    for g in result['grouped'][stuff]['groups']:
                        options.append(g['groupValue'])
                    content['options'] = options
                # append the final content
                process_list.append(content)
        try:
            for url in urls:
                http_client.fetch(
                    url,
                    callback=handle_request
                )
            while True:
                # this probably make no sense
                # we're just trying to sleep for a nano second in here...
                # or maybe just a millisecond?, I don't know man.
                yield gen.sleep(0.0001)
                if len(process_list) == len(urls):
                    break
                # who fucking cares..
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(process_list)

    @gen.coroutine
    def get_unique_querys(self, struct):
        '''
            Get unique list from Solr
        '''
        search_index = 'treehouse_unit_index'
        query = 'uuid_register:*'
        filter_query = 'uuid_register:*'
        unique_list = []
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
                        self.solr,
                        '/query/',
                        search_index,
                        '?wt=json&q=uuid_register:*&fl=',
                        key,
                        '_register&fq=uuid_register:*&group=true&group.field=',
                        key,
                        '_register'))
                    unique_list.append(url)
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
                        self.solr,
                        '/query/',
                        search_index,
                        '?wt=json&q=uuid_register:*&fl=',
                        key,
                        '_register&fq=uuid_register:*&group=true&group.field=',
                        key,
                        '_register'))
                    unique_list.append(url)
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        finally:
            raise gen.Return(unique_list)

    @gen.coroutine
    def patch_on_resource(self, resource, resource_uuid):
        '''
            Patch on resource
        '''
        # url building
        url = "https://{0}/{1}/{2}".format(
            self.solr, resource, resource_uuid
        )
        logging.info(url)
        # response message
        got_response = []
        body = json.dumps({'units':['resource_uuid']})
        message = {'message': 'not found'}
        def handle_request(response):
            '''
                Request Async Handler
            '''
            if response.error:
                got_response.append({'error':True, 'message': response.error})
            else:
                got_response.append(json.loads(response.body))
        try:
            http_client.fetch(
                url,
                body=body,
                method='PATCH',
                callback=handle_request
            )
            while len(got_response) == 0:
                # don't be careless with the time.
                yield gen.sleep(0.0020)
            stuff = got_response[0]
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        raise gen.Return(message)

    @gen.coroutine
    def get_unit(self, account, unit_uuid):
        '''
            Get unit
        '''
        search_index = 'treehouse_unit_index'
        query = 'uuid_register:{0}'.format(unit_uuid)
        filter_query = 'account_register:{0}'.format(account)
        # url building
        url = "https://{0}/search/query/{1}?wt=json&q={2}&fq={3}".format(
            self.solr, search_index, query, filter_query
        )
        got_response = []
        # response message
        message = {'message': 'not found'}
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
                    (key.split('_register') or ('_set')[0][1], value)
                    for (key, value) in response_doc.items()
                    if key not in IGNORE_ME
                )
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)
        raise gen.Return(message)

    @gen.coroutine
    def get_unit_list(self, account, start, end, lapse, status, page_num):
        '''
            Get unit list
        '''
        search_index = 'treehouse_unit_index'
        query = 'uuid_register:*'
        filter_query = 'account_register:{0}'.format(account)
        # shit required on pagination of results
        page_num = int(page_num)
        page_size = self.settings['page_size']
        start_num = page_size * (page_num - 1)
        # url of what?
        url = "https://{0}/search/query/{1}?wt=json&q={2}&fq={3}&start={4}&rows={5}".format(
            self.solr, search_index, query, filter_query, start_num, page_size
        )
        logging.warning('check this url')
        logging.warning(url)
        # von_count
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
    def new_unit(self, struct):
        '''
            New query event
        '''
        # currently we are changing this in two steps, first create de index with a structure file
        search_index = 'treehouse_unit_index'
        # on the riak database with riak-admin bucket-type create `bucket_type`
        # remember to activate it with riak-admin bucket-type activate
        bucket_type = 'treehouse_unit'
        # the bucket name can be dynamic
        bucket_name = 'units'
        try:
            event = units.Unit(struct)
            event.validate()
            event = clean_structure(event)
        except Exception, e:
            raise e
        try:
            message = event.get('uuid')
            structure = {
                "uuid": str(event.get('uuid', str(uuid.uuid4()))),
                "account": str(event.get('account', 'pebkac')),
                "name": str(event.get('name', '')),
                "style": str(event.get('style', '')),
                "description": str(event.get('description', '')),
                "payload": str(event.get('payload', '')),
                "status": str(event.get('status', '')),
                "region": str(event.get('region', '')),
                "ranking": str(event.get('ranking', '')),
                "public": str(event.get('public', '')),
                "checksum": str(event.get('checksum', '')),
                "checked": str(event.get('checked', '')),
                "checked_by": str(event.get('checked_by', '')),
                "checked_at": str(event.get('checked_at', '')),
                "last_update_at": str(event.get('last_update_at', '')),
                "last_update_by": str(event.get('last_update_by', '')),
                "url": str(event.get('url', '')),
                "labels": str(event.get('labels', '')),
                "history": str(event.get('history', '')),
                "hashs": str(event.get('hashs', '')),
                "resource": str(event.get('resource', '')),
                "resource_uuid": str(event.get('resource_uuid', '')),
                "active": str(event.get('active', '')),
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
    def modify_unit(self, account, unit_uuid, struct):
        '''
            Modify query
        '''
        # riak search index
        search_index = 'treehouse_unit_index'
        # riak bucket type
        bucket_type = 'treehouse_units'
        # riak bucket name
        bucket_name = 'units'
        # solr query
        query = 'uuid_register:{0}'.format(unit_uuid.rstrip('/'))
        # filter query
        filter_query = 'account_register:{0}'.format(account)
        # search query url
        url = "https://{0}/search/query/{1}?wt=json&q={2}&fq={3}".format(
            self.solr, search_index, query, filter_query
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
    def remove_unit(self, account, unit_uuid):
        '''
            Remove unit
        '''
        # missing history
        struct = {}

        struct['status'] = 'deleted'

        test = yield self.modify_unit(account, unit_uuid, struct)

        logging.info(test)
        
        raise gen.Return(test)