FROM integration-bench/osm2pgsql:latest

# Build phase environment variables

ARG PGHOST
ARG PGUSER
ARG PGPASSWORD
ARG PGDATABASE

# Get build packages

RUN apt update && \
    apt install -y autoconf apache2-dev libtool libxml2-dev libproj-dev gdal-bin libmapnik-dev npm python3-mapnik python3-psycopg2 python3-distutils mapnik-utils

# Reuse renderer user from oms2pgsql image

USER renderer

# Install mod_tile

WORKDIR /home/renderer/src
RUN git clone -b switch2osm git://github.com/SomeoneElseOSM/mod_tile.git
WORKDIR /home/renderer/src/mod_tile
RUN ./autogen.sh && ./configure && make
USER root
RUN make install && make install-mod_tile && ldconfig
WORKDIR /home/renderer/src/openstreetmap-carto

# Set database information in project.mml
RUN sed -i 's/    dbname: "gis"/    host: "'"${PGHOST}"'"\n    user: "'"${PGUSER}"'"\n    password: "'"${PGPASSWORD}"'"\n    dbname: "'"${PGDATABASE}"'"/g' project.mml
RUN head -50 project.mml
# Build style

RUN npm install -g carto
RUN carto project.mml > mapnik.xml

# Get shapefiles for low zoom levels. These shapefiles are not inserted into the database
RUN python3 scripts/get-shapefiles.py

# Get fonts

RUN apt-get install -y fonts-noto-cjk fonts-noto-hinted fonts-noto-unhinted ttf-unifont

# Configure renderd

RUN sed -i 's/renderaccount/renderer/g' /usr/local/etc/renderd.conf \
  && sed -i 's/hot/tile/g' /usr/local/etc/renderd.conf
RUN sed -i "s/XML=.*/XML=\/home\/renderer\/src\/openstreetmap-carto\/mapnik.xml/g" /usr/local/etc/renderd.conf
RUN cat /usr/local/etc/renderd.conf

# Create working dirs 

RUN mkdir /var/lib/mod_tile
RUN mkdir /var/run/renderd

# data already imported by osm2pgsql. Is it necessary ?
# RUN touch /var/lib/mod_tile/planet-import-complete

# Install apache2 and configure it

RUN apt install -y apache2
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" >> /etc/apache2/conf-available/mod_tile.conf
RUN a2enconf mod_tile
#RUN a2enconf mod_headers
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf
RUN cat /etc/apache2/sites-available/000-default.conf

RUN apt install -y sudo
RUN chown renderer /var/lib/mod_tile
RUN chown renderer /var/run/renderd

COPY ./run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]

# Add webpages

COPY  ./www/leaflet-demo.html /var/www/html/index.html
COPY  ./www/leaflet.css  /var/www/html/leaflet.css
COPY  ./www/leaflet.js  /var/www/html/leaflet.js

# Add render_list_geo.pl to pre-render some tiles (performance benchmarks, etc)

WORKDIR /
RUN git clone https://github.com/alx77/render_list_geo.pl.git georender
RUN mv georender/render_list_geo.pl render_list_geo.pl
RUN rm -rf georender

CMD []
EXPOSE 80
