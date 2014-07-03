#!/bin/bash -ex

# Increase the maximum number of open files
# The container need to be run in privileged mode or this will throw an error
ulimit -n 65535

/srv/kazoup/lifecycle/wait_for_mongo_primary.py 2>&1

exec /srv/elasticsearch/bin/elasticsearch -Des.max-open-files=true 2>&1
