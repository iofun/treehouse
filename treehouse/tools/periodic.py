# -*- coding: utf-8 -*-
'''
    Overlord tools system periodic functions.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Jean Chassoul'


import logging
from tornado import httpclient
import ujson as json
import uuid
import urllib
import queries

from tornado import gen

from treehouse.system import imps


httpclient.AsyncHTTPClient.configure('tornado.curl_httpclient.CurlAsyncHTTPClient')



@gen.coroutine
def set_alert_checked(db, alert_uuid):
    '''
        Set alert checked flag 
    '''
    try:
        result = yield db.alerts.update(
            {'uuid': alert_uuid}, 
            {'$set': {'checked': True}}
        )
    except Exception, e:
        logging.error(e)
        message = str(e)

    raise gen.Return(result)

@gen.coroutine
def send_alert_message(address, message, mailgun_url, mailgun_key):
    '''
        Send alert message by email
    '''

    url = mailgun_url

    # TODO: make it work with curl and remove requests hack.

    def handle_request(response):
        if response.error:
            logging.error(response.error)
        else:
            logging.info('ok %s' % str(response.body))

    
    msgdict = json.loads(message)

    logging.error('message dictionary {0}'.format(msgdict))

    message = '''THIS E-MAIL CONTAINS IMPORTANT INFORMATION PERTAINING TO YOUR ABILITY TO ACCESS THE snakeyevape.com  SYSTEM & REGISTRY - DO NOT LOSE THIS MESSAGE! Pursuant to your request, a password was generated for your account {0} password: {1} has been sent to {2} email.
    '''.format(msgdict.get('account'),msgdict.get('password'),msgdict.get('email'))


    try:
        message = requests.post(
            url,
            auth=("api", mailgun_key),
            data={"from": "Code Machine <no-reply@codemachine.io>",
                  "to": '''[{0},{1},
                            {2},{3},
                            {4},{5},
                            {6},{7}]'''.format(
                                            address, 
                                            msgdict.get('email'),
                                            'advexe@gmail.com',
                                            'jhernandez@codemachine.io',
                                            'gcastillo@codemachine.io',
                                            'lford@snakeyevapeshop.com',
                                            'jchassoul@codemachine.io',
                                            'info@snakeyevapeshop.com'),
                  "subject": msgdict.get('subject', "Regarding your SnakeyeVape.com Wholesale user account"),
                  "text": msgdict.get('text', message)}
        )
    except Exception, e:
        logging.error(e)
        message = str(e)

    raise gen.Return(message)

@gen.coroutine
def consume_alert_callback(db, mailgun_key, mailgun_url):
    '''
        periodic consume alert callback function
    '''
    alerts = []

    try:
        query = db.alerts.find({
            'checked':False
        }, {'_id':0})
        
        while (yield query.fetch_next):
            alert = query.next_object()
            alerts.append(alert)
            yield set_alert_checked(db, alert.get('uuid'))
            yield send_alert_message(alert.get('email'), alert.get('body'), mailgun_url, mailgun_key)
    
    except Exception, e:
        message = str(e)
        logging.error(message)
        

    raise gen.Return(alerts)
