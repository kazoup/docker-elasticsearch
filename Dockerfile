FROM phusion/baseimage:0.9.8

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y wget openjdk-6-jre

# add the kazoup dev ssh key
ADD docker/id_rsa.kazoup_dev.pub /tmp/id_rsa.kazoup_dev.pub
RUN cat /tmp/id_rsa.kazoup_dev.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.kazoup_dev.pub
#RUN chmod 600 /root/.ssh/authorized_keys

ADD docker/packages.txt /tmp/packages.txt
RUN apt-get update \
    && cat /tmp/packages.txt | xargs apt-get -y --force-yes install --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.npm

ADD docker/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.npm

# generate a host key
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN cd /srv \
    && wget -O elasticsearch.tgz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.tar.gz \
    && tar zxf elasticsearch.tgz \
    && mv /srv/elasticsearch-1.0.1 /srv/elasticsearch \
    && rm -rf /srv/*.tgz

RUN /srv/elasticsearch/bin/plugin --install elasticsearch/elasticsearch-mapper-attachments/2.0.0.RC1
RUN /srv/elasticsearch/bin/plugin --install elasticsearch-river-mongodb --url https://github.com/NicolasTr/elasticsearch-river-mongodb/releases/download/2.0.0-kazoup/elasticsearch-river-mongodb-2.0.0-kazoup-4.zip
RUN /srv/elasticsearch/bin/plugin --install mobz/elasticsearch-head
RUN /srv/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
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
