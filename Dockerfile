FROM confluentinc/cp-server-connect:7.2.2
USER root:root
COPY ./plugins/ /usr/share/java/acl/
USER kafka:kafka
