FROM maven:3.8.4-eclipse-temurin-8 AS BUILDER
RUN apt-get -y update
RUN apt-get -y install git
COPY pom.xml /tmp/
RUN mvn -B dependency:go-offline -f /tmp/pom.xml -s /usr/share/maven/ref/settings-docker.xml
COPY src /tmp/src/
COPY .git/ /tmp/.git/
WORKDIR /tmp/
RUN mvn -B -s /usr/share/maven/ref/settings-docker.xml --batch-mode package -P release

FROM openjdk:8
# https://github.com/docker-library/openjdk/issues/145#issuecomment-334561903
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=894979
RUN rm /etc/ssl/certs/java/cacerts ; update-ca-certificates -f
RUN mkdir -p /opt/secor
ADD target/secor-*-bin.tar.gz /opt/secor/

COPY src/main/scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
