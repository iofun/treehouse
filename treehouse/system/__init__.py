# -*- coding: utf-8 -*-
'''
    Treehouse system logic functions.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License.
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'


import uuid

import logging


def process_message(message):
    '''
        process_message system function
    '''
    logging.warning("Processing ... {0}".format(message))

def spawn(message):
    '''
        Spawn process, return new uuid
    '''
    logging.info("Spawn process {0}".format(message))

def link(message):
    '''
        Link processes
    '''
    logging.info("Link processes {0}".format(message))

def spawn_link(message):
    '''
        Spawn link processes
    '''
    logging.info("Spawn new process, {0} return Received process uuid".format(message))

def spawn_monitor(message):
    '''
        Spawn monitor processes
    '''
    logging.info("Spawn new process, {0} return Received process uuid".format(message))

def monitor(message):
    '''
        Monitor processes
    '''
    logging.info("Monitor processes {0}".format(message))

def register(message):
    '''
        Register process uuid
    '''
    logging.info("Received message: %s" % message)

def get_command(message):
    '''
        get_command system function
    '''
    logging.warning('Received control command: {0}'.format(message))
    '''
        #Current commands:

        Action, Build, Cancel, Destination, Hold,
        Gather, Load, Unload, Advanced, Repair,
        Stop, Patrol, Move, Continue, Exit
    '''

    if message[0] == "Action":
        logging.warning('Received action command')
    if message[0] == "Build":
        logging.warning('Received build command')
    if message[0] == "Cancel":
        logging.warning('Received cancel command')
    if message[0] == "Destination":
        logging.warning('Received destination command')
    if message[0] == "Hold":
        logging.warning('Received hold command')
    if message[0] == "Gather":
        logging.warning('Received gather command')
    if message[0] == "Load":
        logging.warning('Received load command')
    if message[0] == "Unload":
        logging.warning('Received unload command')
    if message[0] == "Advanced":
        logging.warning('Received advanced command')
    if message[0] == "Repair":
        logging.warning('Received repair command')
    if message[0] == "Stop":
        logging.warning('Received stop command')
    if message[0] == "Patrol":
        logging.warning('Received patrol command')
    if message[0] == "Move":
        logging.warning('Received move command')
    if message[0] == "Continue":
        logging.warning('Received continue command')
    if message[0] == "Exit":
        logging.warning('Received exit command, client will stop receiving messages')
        should_continue = False
        ioloop.IOLoop.instance().stop()