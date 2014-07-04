#!/usr/bin/env python

from getenv import env
from mongoengine import connect, ConnectionError
import time
import sys

MONGO_HOST = env('MONGODB_1_PORT_27017_TCP_ADDR')
MONGO_PORT = int(env('MONGODB_1_PORT_27017_TCP_PORT') or 0)
MONGO_REPLICA_SET = 'rs0'
MONGO_DBNAME = 'appliance'

n_retry = 60
delay = 5

for i in range(n_retry):
    try:
        print "Connecting to mongo"
        db = connect(MONGO_DBNAME, alias='try {}'.format(i), host=MONGO_HOST, port=MONGO_PORT)
        print "Connecting to mongo - ok"
        print "Checking if mongo is a primary"
        assert db.is_primary
        print "Checking if mongo is a primary - ok"
        sys.stdout.flush()
        break
    except ConnectionError as e:
        print "Connecting to mongo - fail (retrying in {}s)".format(delay)
        sys.stdout.flush()
    except AssertionError as e:
        db.disconnect()
        del db
        print "Checking if mongo is a primary - fail (retrying in {}s)".format(delay)
        sys.stdout.flush()
    time.sleep(delay)
else:
    raise
