#
# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG SPARK_IMAGE=registry.access.redhat.com/ubi8/ubi:8.1

FROM golang:1.19.2-alpine as builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# Cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source code
COPY main.go main.go
COPY pkg/ pkg/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o /usr/bin/spark-operator main.go

FROM --platform=linux/amd64 ${SPARK_IMAGE} 
USER root
COPY --from=builder /usr/bin/spark-operator /usr/bin/

RUN yum update -y && yum install -y wget python38
# RUN cd /opt/
# RUN wget https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tgz
# RUN tar xzf Python-3.8.3.tgz  
# RUN cd Python-3.8.3  
# RUN ./configure --enable-optimizations 
# RUN make altinstall  
# RUN pip3 -V  

# RUN yum update -y \
#     && yum install -y openssl curl\
#     && rm -rf /var/lib/apt/lists/*
# COPY hack/gencerts.sh /usr/bin/

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ADD https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz ./spark-3.3.1-bin-hadoop3.tgz 
RUN tar -xvf ./spark-3.2.3-bin-hadoop3.2.tar
RUN cp -r spark-3.2.3-bin-hadoop3.2/ /opt/spark/

ENV SPARK_HOME="/opt/spark"
ENV DOCKER_DEFAULT_PLATFORM=linux/amd64

COPY entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
