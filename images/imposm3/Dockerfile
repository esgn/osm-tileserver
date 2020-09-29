FROM debian:buster

RUN apt-get update \
    && apt-get install -y postgresql-client wget make golang git-core mercurial libleveldb-dev libgeos-dev libgeos++-dev osmosis python-nose python-psycopg2 python-shapely

ENV GOPATH=/usr/local/src/go
ENV PATH="$GOPATH/bin:${PATH}"

RUN mkdir -p /usr/local/src/go
WORKDIR /usr/local/src/go

RUN go get github.com/omniscale/imposm3
RUN go install github.com/omniscale/imposm3/cmd/imposm

RUN echo "export PATH=$PATH" > /etc/environment

COPY imposm3-example-mapping.yml /
