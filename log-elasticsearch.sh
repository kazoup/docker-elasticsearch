#!/bin/bash -ex

mkdir -p /var/log/kazoup/elasticsearch_runit
exec svlogd -tt /var/log/kazoup/elasticsearch_runit
