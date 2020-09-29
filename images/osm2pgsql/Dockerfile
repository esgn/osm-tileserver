FROM debian:buster

# Build phase environment variables

ARG OSM_CARTO_VERSION
ARG OSM2PGSQL_VERSION

# Install osm2pgsql

RUN apt-get update \
    && apt-get install -y wget postgresql-client make git-core cmake g++ libboost-dev libboost-system-dev libboost-filesystem-dev libexpat1-dev zlib1g-dev libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev lua5.2 liblua5.2-dev

RUN wget https://github.com/openstreetmap/osm2pgsql/archive/${OSM2PGSQL_VERSION}.tar.gz \
    && tar xvzf ${OSM2PGSQL_VERSION}.tar.gz

RUN mv osm2pgsql* /usr/local/osm2pgsql

RUN cd /usr/local/osm2pgsql \
    && mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && rm -rf /usr/local/osm2pgsql

# Create renderer user

RUN adduser --disabled-password --gecos "" renderer
USER renderer

RUN mkdir /home/renderer/src
WORKDIR /home/renderer/src

# Get style

RUN wget https://github.com/gravitystorm/openstreetmap-carto/archive/v${OSM_CARTO_VERSION}.tar.gz
RUN tar zxvf v${OSM_CARTO_VERSION}.tar.gz
RUN mv openstreetmap-carto-${OSM_CARTO_VERSION} openstreetmap-carto

# Install docker client to trigger shutdown of postgis container
USER root
RUN apt-get install -y docker.io

# Install import script 
COPY ./import.sh /import.sh
RUN chmod +x /import.sh

ENTRYPOINT ["/import.sh"]
CMD []
