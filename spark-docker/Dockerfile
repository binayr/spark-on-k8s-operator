ARG SPARK_IMAGE=registry.access.redhat.com/ubi8/ubi:8.1

FROM --platform=linux/amd64 ${SPARK_IMAGE} 
USER root
WORKDIR /opt/

RUN yum update -y && yum install -y wget python38

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ADD https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3-scala2.13.tgz /opt/
RUN tar -xvf /opt/spark-3.3.1-bin-hadoop3-scala2.13.tgz
RUN cp -r spark-3.3.1-bin-hadoop3-scala2.13/ /opt/spark/

ENV DOCKER_DEFAULT_PLATFORM=linux/amd64
ENV SPARK_HOME="/opt/spark"

RUN rm -rf spark-3.3.1-bin-hadoop3-scala2.13
RUN rm spark-3.3.1-bin-hadoop3-scala2.13.tgz

COPY entrypoint.sh /opt/
# ENTRYPOINT ["/opt/entrypoint.sh"]
