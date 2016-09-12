# -*- coding: utf-8 -*-
'''
    overlord Imps system logic.
'''

# This file is part of overlord.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import arrow

import uuid

import logging

from tornado import gen

from overlord.messages import imps, nodes

from overlord.tools import clean_structure, clean_results


class Imps(object):
    '''
        Overlord Imps

        You thought an imp was a cute little dude in a red suit with a pitchfork. 
        Where did these bastards come from? They heave balls o' fire down 
        your throat and take several bullets to die. 

        It's time to find a tool better than that crowbar if you're going to face more than one of these.
    '''

    @gen.coroutine
    def get_imp_list(self, account, checked, page_num):
        '''
            Get Imp list
        '''
        page_num = int(page_num)
        page_size = self.settings.get('page_size')
        imp_list = []

        # remove phone_2, phone_3 and imp_requests from query stuff and db.
        query = self.db.imps.find(
            {
                'account':account,
                'checked':checked
            },
            {
                '_id':0,
                'phone_2':0,
                'phone_3':0,
                'imp_requests':0
            }
        )

        q = query

        q = q.sort([('_id', -1)]).skip(int(page_num) * page_size).limit(page_size)

        try:
            while (yield q.fetch_next):
                imp = imps.Imp(q.next_object())
                imp_list.append(clean_structure(imp))
        except Exception, e:
            logging.exception(e)
            raise gen.Return(e)

        finally:
            raise gen.Return(imp_list)

    @gen.coroutine
    def get_imp(self, account, imp_uuid):
        '''
            Get Imp
        '''
        message = None
        logging.info('{0} get imp {1}'.format(account, imp_uuid))
        try:
            result = yield self.db.imps.find_one(
                {'account':account,
                 'uuid': imp_uuid},
                {'_id':0, 'phone_2':0, 'phone_3':0, 'imp_requests':0} # remove this stuff from db.
            )

            logging.info('{0} this is the result'.format(str(result)))
            if result:
                imp = imps.imp(result)
                imp.validate()
                message = clean_structure(imp)
        except Exception, e:
            logging.exception(e)
            raise e
        finally:
            raise gen.Return(message)

    @gen.coroutine
    def new_imp(self, struct):
        '''
            New Imp
        '''
        # if check dir fail remove directory uuid
        if not struct.get('has_directory', False):
            struct.pop('directory_uuid', None)
            
        try:
            imp = imps.imp(struct)
            imp.validate()
            imp = clean_structure(imp)
        except Exception, e:
            logging.error(e)
            raise e

        try:
            result = yield self.db.imps.insert(imp)
            message = imp.get('uuid')
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(message)

    @gen.coroutine
    def modify_imp(self, account, imp_uuid, struct):
        '''
            Modify Imp
        '''
        try:
            imp = imps.Modifyimp(struct)
            imp.validate()
            imp = clean_structure(imp)
        except Exception, e:
            logging.error(e)
            raise e

        try:
            result = yield self.db.imps.update(
                {'account':account,
                 'uuid':uuid.UUID(imp_uuid)},
                {'$set':imp}
            )
            logging.info(result)            
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(bool(result.get('n')))

    @gen.coroutine
    def replace_imp(self, account, imp_uuid, struct):
        '''
            Replace Imp
        '''
        try:
            imp = imps.imp(struct)
            imp.validate()
            imp = clean_structure(imp)
        except Exception, e:
            logging.error(e)
            raise e

        try:
            result = yield self.db.imps.update(
                {'account':account,
                 'uuid':uuid.UUID(imp_uuid)},
                {'$set':imp}
            )
            logging.info(result)            
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(bool(result.get('n')))

    @gen.coroutine
    def remove_imp(self, account, imp_uuid):
        '''
            Remove Imp
        '''
        message = None
        try:
            message = yield self.db.imps.remove(
                {'account':account, 'uuid':uuid.UUID(imp_uuid)}
            )
        except Exception, e:
            logging.error(e)
            message = str(e)

        raise gen.Return(bool(message.get('n')))