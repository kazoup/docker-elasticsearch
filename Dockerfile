FROM phusion/baseimage:0.9.8

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y wget openjdk-6-jre

RUN cd /srv \
    && wget -O elasticsearch.tgz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.tar.gz \
    && tar zxf elasticsearch.tgz \
    && mv /srv/elasticsearch-1.0.1 /srv/elasticsearch \
    && rm -rf /srv/*.tgz

RUN /srv/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-mapper-attachments/2.0.0.RC1
RUN /srv/elasticsearch/bin/plugin --install com.github.richardwilly98.elasticsearch/elasticsearch-river-mongodb/2.0.0
RUN /srv/elasticsearch/bin/plugin --install mobz/elasticsearch-head
RUN /srv/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
ADD elasticsearch.yml /srv/elasticsearch/config/

RUN mkdir -p /data/elasticsearch

RUN mkdir -p /etc/service/elasticsearch
ADD run-elasticsearch.sh /etc/service/elasticsearch/run

EXPOSE 22
EXPOSE 9200
EXPOSE 9300
CMD ["/sbin/my_init"]
