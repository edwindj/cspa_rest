FROM ubuntu:14.04
MAINTAINER Edwin de Jonge


ADD ./bootstrap.sh ./bootstrap.sh
RUN ./bootstrap.sh
EXPOSE 8080

WORKDIR /cspa_rest
CMD ["nodejs", "server.js"]
