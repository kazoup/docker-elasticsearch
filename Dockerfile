FROM phusion/baseimage:0.9.8

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y wget openjdk-6-jre

# add the kazoup dev ssh key
ADD id_rsa.kazoup_dev.pub /tmp/id_rsa.kazoup_dev.pub
RUN cat /tmp/id_rsa.kazoup_dev.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.kazoup_dev.pub
#RUN chmod 600 /root/.ssh/authorized_keys

# generate a host key
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

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

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
EXPOSE 22
EXPOSE 9200
EXPOSE 9300
