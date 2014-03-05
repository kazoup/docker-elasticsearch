FROM ubuntu:13.10

RUN apt-get update
RUN apt-get upgrade -y

# Configure ssh
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
RUN echo "root:root" | chpasswd
RUN sed -i "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config

RUN apt-get install -y supervisor wget openjdk-6-jre

RUN cd /srv && wget -O elasticsearch.tgz https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.tar.gz
RUN cd /srv && tar zxf elasticsearch.tgz

RUN mv /srv/elasticsearch-1.0.1 /srv/elasticsearch
RUN rm -rf /srv/*.tgz

RUN /srv/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-mapper-attachments/2.0.0.RC1
RUN /srv/elasticsearch/bin/plugin --install com.github.richardwilly98.elasticsearch/elasticsearch-river-mongodb/2.0.0
RUN /srv/elasticsearch/bin/plugin -install mobz/elasticsearch-head
RUN /srv/elasticsearch/bin/plugin -install lukas-vlcek/bigdesk

ADD elasticsearch.yml /srv/elasticsearch/config/

ADD supervisord.conf /etc/supervisor.conf

EXPOSE 22
EXPOSE 9200
EXPOSE 9300
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]
