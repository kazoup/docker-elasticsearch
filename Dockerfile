FROM phusion/baseimage:0.9.8

RUN apt-get update
RUN apt-get upgrade -y

# See https://github.com/jplock/docker-oracle-java7/blob/master/Dockerfile
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

# add the kazoup dev ssh key
ADD docker/id_rsa.kazoup_dev.pub /tmp/id_rsa.kazoup_dev.pub
RUN cat /tmp/id_rsa.kazoup_dev.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.kazoup_dev.pub
#RUN chmod 600 /root/.ssh/authorized_keys

# generate a host key
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN cd /srv \
    && wget -O elasticsearch.tgz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.tar.gz \
    && tar zxf elasticsearch.tgz \
    && mv /srv/elasticsearch-1.1.0 /srv/elasticsearch \
    && rm -rf /srv/*.tgz

RUN /srv/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-mapper-attachments/2.0.0
RUN /srv/elasticsearch/bin/plugin --install mobz/elasticsearch-head
RUN /srv/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
RUN /srv/elasticsearch/bin/plugin --install com.yakaz.elasticsearch.plugins/elasticsearch-action-updatebyquery/2.0.1
RUN /srv/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-cloud-aws/2.1.1
ADD docker/elasticsearch.yml /srv/elasticsearch/config/

RUN mkdir -p /data/elasticsearch

RUN mkdir -p /etc/service/elasticsearch
RUN mkdir -p /var/log/kazoup
ADD docker/run-elasticsearch.sh /etc/service/elasticsearch/run
ADD docker/log-elasticsearch.sh /etc/service/elasticsearch/log/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]
EXPOSE 22
EXPOSE 9200
EXPOSE 9300
