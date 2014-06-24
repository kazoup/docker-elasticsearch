#!/bin/bash -ex

# Increase the maximum number of open files
# The container need to be run in privileged mode or this will throw an error
ulimit -n 65535

exec /srv/elasticsearch/bin/elasticsearch -f 2>&1
