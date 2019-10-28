FROM nginx:1.17

RUN apt-get update && apt-get install -y apt-transport-https
RUN apt-get update && apt-get install -y libssl-dev
RUN apt-get update && apt-get install -y wget
RUN apt-get update && apt-get install -y unzip

RUN mkdir -p /home/

RUN wget -O /home/consul-template.zip \
    https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_386.zip
RUN unzip /home/consul-template.zip -d /usr/bin
RUN chmod +x /usr/bin/consul-template
RUN rm /home/consul-template.zip
RUN mkdir /var/log/consul-template

COPY nginx.conf /etc/nginx/nginx.conf
COPY openlmis.conf /etc/consul-template/openlmis.conf
COPY run.sh /home/run.sh

VOLUME [ "/var/log/nginx", "/var/log/consul-template" ]

ENTRYPOINT [ "/home/run.sh" ]
