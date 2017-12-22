# -*- coding: utf-8 -*-
'''
    Treehouse apps system logic.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid
import logging
import ujson as json
from tornado import gen
from schematics.types import compound
from treehouse.messages import apps
from treehouse.messages import BaseResult
from treehouse.structures.apps import AppMap
from riak.datatypes import Map
from treehouse.tools import clean_structure, clean_results
from tornado import httpclient as _http_client


_http_client.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')
http_client = _http_client.AsyncHTTPClient()


class AppsResult(BaseResult):
    '''
        List result
    '''
    results = compound.ListType(compound.ModelType(apps.App))


class Apps(object):
    '''
        Apps
    '''
    @gen.coroutine
    def get_query_values(self, urls):
        '''
            Process grouped values from Solr
        '''
        message = []
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
                message.append(content)
        try:
            for url in urls:
                http_client.fetch(
                    url,
                    callback=handle_request
                )
            while True:
                #  I don't know man.
                yield gen.sleep(0.0020)
                if len(message) == len(urls):
                    break
                # who fucking cares..
        except Exception as message:
            logging.exception(message)
        return message

    @gen.coroutine
    def get_unique_querys(self, struct):
        '''
            Get unique list from Solr
        '''
        search_index = 'treehouse_app_index'
        query = 'uuid_register:*'
        filter_query = 'uuid_register:*'
        message = []
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
                    message.append(url)
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
                    message.append(url)
        except Exception as message:
            logging.exception(message)
        return message

    @gen.coroutine
    def get_app(self, account, app_uuid):
        '''
            Get app
        '''
        search_index = 'treehouse_app_index'
        query = 'uuid_register:{0}'.format(app_uuid)
        filter_query = 'account_register:{0}'.format(account.decode('utf-8'))
        # build the url
        url = "https://{0}/search/query/{1}?wt=json&q={2}&fq={3}".format(
            self.solr, search_index, query, filter_query
        )
        logging.warning(url)
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
                    (key.split('_register')[0], value)
                    for (key, value) in response_doc.items()
                    if key not in IGNORE_ME
                )
        except Exception as message:
            logging.exception(message)
        return message

    @gen.coroutine
    def get_app_list(self, account, start, end, lapse, status, page_num):
        '''
            Get app list
        '''
        search_index = 'treehouse_app_index'
        query = 'uuid_register:*'
        filter_query = 'account_register:{0}'.format(account.decode('utf-8'))
        page_num = int(page_num)
        page_size = self.settings['page_size']
        start_num = page_size * (page_num - 1)
        url = "https://{0}/search/query/{1}?wt=json&q={2}&fq={3}&start={4}&rows={5}".format(
            self.solr, search_index, query, filter_query, start_num, page_size
        ).replace(' ', '')
        logging.warning('check this url *---->' + url)
        #logging.warning(url)
        von_count = 0
        message = {
            'error': False
        }
        def handle_request(response):
            '''
                Request Async Handler
            '''
            if response.error:
                logging.error(response.error)
                message['error'] = True
                message['message'] = response.error
            else:
                message['message'] = json.loads(response.body)
        try:
            http_client.fetch(
                url,
                callback=handle_request
            )
            while (len(message.keys())) <= 1:
                yield gen.sleep(0.0020)
                # don't be careless with the time.
        except Exception as error:
            message['error'] = True
            message['message'] = error

        message = (message['message'] if not message['error'] else message)

        logging.warning(message)

        return message

    @gen.coroutine
    def new_app(self, struct):
        '''
            New app event
        '''
        search_index = 'treehouse_app_index'
        bucket_type = 'treehouse_app'
        bucket_name = 'apps'
        try:
            event = apps.App(struct)
            event.validate()
            event = clean_structure(event)
        except Exception as error:
            raise error
        try:
            structure = {
                "uuid": str(event.get('uuid', str(uuid.uuid4()))),
                "url": str(event.get('url', '')),
                "account": str(event.get('account', 'pebkac')),
                "checksum": str(event.get('checksum', '')),
                "payload": str(event.get('payload', '')),
                "public": str(event.get('public', '')),
                "frames": str(event.get('frames', '')),
                "labels": str(event.get('labels', '')),
                "hashs": str(event.get('hashs', '')),
                "status": str(event.get('status', '')),
                "created_by": str(event.get('created_by', '')),
                "created_at": str(event.get('created_at', '')),
                "updated": str(event.get('updated', '')),
                "last_update_by": str(event.get('last_update_by', '')),
                "last_update_at": str(event.get('last_update_at', '')),
                "checked": str(event.get('checked', '')),
                "checked_by": str(event.get('checked_by', '')),
                "checked_at": str(event.get('checked_at', '')),
                "resource": str(event.get('resource', '')),
                "resource_uuid": str(event.get('resource_uuid', '')),
                "active": str(event.get('active', '')),
            }
            result = AppMap(
                self.kvalue,
                bucket_name,
                bucket_type,
                search_index,
                structure
            )
            message = structure.get('uuid')
        except Exception as error:
            logging.error(error)
            message = str(error)
        raise gen.Return(message)

    @gen.coroutine
    def modify_app(self, account, app_uuid, struct):
        '''
            Modify app
        '''
        # riak search index
        search_index = 'treehouse_app_index'
        # riak bucket type
        bucket_type = 'treehouse_app'
        # riak bucket name
        bucket_name = 'apps'
        # solr query
        query = 'uuid_register:{0}'.format(app_uuid.rstrip('/'))
        # filter query
        filter_query = 'account_register:{0}'.format(account.decode('utf-8'))
        # search query url
        url = "https://{0}/search/query/{1}?wt=json&q={2}&fq={3}".format(
            self.solr, search_index, query, filter_query
        )
        # pretty please, ignore this list of fields from database.
        IGNORE_ME = ("_yz_id","_yz_rk","_yz_rt","_yz_rb","checked","keywords")
        # on this resource work with this list of sets
        SETS = ('frames', 'labels', 'hashs')
        # got callback response?
        got_response = []
        # update_complete = False
        message = {'update_complete':False}
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
            response = got_response[0].get('response')['docs'][0]
            riak_key = str(response['_yz_rk'])

            bucket = self.kvalue.bucket_type(bucket_type).bucket('{0}'.format(bucket_name))
            bucket.set_properties({'search_index': search_index})

            app = Map(bucket, riak_key)
            app.reload()

            for key in struct:

                if key not in IGNORE_ME:

                    if key not in SETS:
                        app.registers['{0}'.format(key)].assign(str(struct.get(key)))
                    else:
                        logging.error(key)
                        app.sets['{0}'.format(key)].add(str(struct.get(key)))

                    app.update()

            update_complete = True
            message['update_complete'] = True
        except Exception as error:
            logging.exception(error)
        return message.get('update_complete', False)

    @gen.coroutine
    def remove_app(self, account, app_uuid):
        '''
            Remove app
        '''
        # missing history
        struct = {}
        struct['status'] = 'deleted'
        message = yield self.modify_app(account, app_uuid, struct)
        raise gen.Return(message)
