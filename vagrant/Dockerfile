FROM ubuntu:14.04
MAINTAINER Edwin de Jonge


ADD ./bootstrap.sh /tmp/bootstrap.sh
RUN chmod +x /tmp/bootstrap.sh
RUN /tmp/bootstrap.sh
EXPOSE 8080

WORKDIR /cspa_rest
CMD ["nodejs", "server.js"]
