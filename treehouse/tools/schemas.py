# -*- coding: utf-8 -*-
'''
    Treehouse sql database schemas.
'''

# This file is part of treehouse.

# Distributed under the terms of the last AGPL License. 
# The full license is in the file LICENCE, distributed as part of this software.

__author__ = 'Team Machine'

import logging
import queries


def ensure_schemas(sql):
    '''        
        ensure_schemas(sql)
    '''
    # the challenge: use corouties to check from treehouse if is needed 
    # to rebuild a sql schema in postgres our sql engine.

    x = sql.query("SELECT now()")
    logging.warning(x)
