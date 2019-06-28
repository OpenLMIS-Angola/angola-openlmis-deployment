FROM certbot/certbot:v0.33.1

COPY log/logback.xml /config/log/logback.xml
COPY scalyr/agent.json /config/scalyr/agent.json
#COPY cert/root.crt /config/cert/root.crt

CMD /bin/true

