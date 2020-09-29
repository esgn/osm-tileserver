FROM integration-bench/osm2pgsql:latest

# Build and install Osmosis

ENV OSMOSIS_VERSION=0.48.2

RUN apt-get update && \
    apt-get -y install curl unzip gdal-bin tar wget bzip2 build-essential clang
    
RUN apt-get -y install default-jre default-jdk gradle git-core

RUN wget https://github.com/openstreetmap/osmosis/archive/${OSMOSIS_VERSION}.tar.gz\
    && tar xvzf ${OSMOSIS_VERSION}.tar.gz

RUN mv osmosis* /usr/local/osmosis
WORKDIR /usr/local/osmosis
RUN ./gradlew assemble
RUN ln -s "$PWD"/package/bin/osmosis /usr/bin/osmosis

# Install osmconvert

RUN apt-get -y install osmctools

# We need mod_tile to use render-expire

RUN apt-get -y install apache2-dev libmapnik-dev
RUN mkdir /src
WORKDIR /src
RUN git clone -b switch2osm git://github.com/SomeoneElseOSM/mod_tile.git
WORKDIR /src/mod_tile
RUN ./autogen.sh && ./configure && make && make install && make install-mod_tile && ldconfig
RUN rm -rf /src

# Get everything ready to run

RUN apt-get install -y cron

ENV WORKDIR_OSMOSIS=/osmosis-workdir
RUN mkdir $WORKDIR_OSMOSIS
RUN mkdir /var/log/tiles

ADD update.sh /update.sh
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /update.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
