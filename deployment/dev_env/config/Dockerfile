FROM certbot/certbot:v0.33.1

COPY log/logback.xml /config/log/logback.xml
COPY scalyr/agent.json /config/scalyr/agent.json
COPY certs_obtaining.sh /config/certs_obtaining.sh

CMD /bin/true
