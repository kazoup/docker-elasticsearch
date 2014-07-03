#!/bin/bash -ex

# Increase the maximum number of open files
# The container need to be run in privileged mode or this will throw an error
ulimit -n 65535

# We give to elasticsearch half the memory of the system
TOTAL_MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')
HALF_MEMORY=$(( ${TOTAL_MEMORY} / 2 ))
export ES_HEAP_SIZE=${HALF_MEMORY}

# See: http://makina-corpus.com/blog/metier/2014/elasticsearch-when-giving-it-more-memory-causes-more-outofmemory-errror
MAX_MEMORY=4000000000
export ES_HEAP_SIZE=$(( ${ES_HEAP_SIZE} > ${MAX_MEMORY} ? ${MAX_MEMORY} : ${ES_HEAP_SIZE} ))

MIN_MEMORY=1500000000
export ES_HEAP_SIZE=$(( ${ES_HEAP_SIZE} > ${MIN_MEMORY} ? ${ES_HEAP_SIZE} : ${MIN_MEMORY} ))

/srv/kazoup/lifecycle/wait_for_mongo_primary.py 2>&1

exec /srv/elasticsearch/bin/elasticsearch -Des.max-open-files=true 2>&1
