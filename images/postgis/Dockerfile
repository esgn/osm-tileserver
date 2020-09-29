FROM postgres:12.4

# Install postgis
RUN apt-get update \
  && apt-get install -y postgresql-12-postgis-3

# Copy configurations
COPY import.conf /import.conf
COPY render.conf /render.conf

# Adapt values to available RAM
WORKDIR /
COPY adapt_conf.sh /adapt_conf.sh
RUN bash adapt_conf.sh

# Create dir for logs in case user activates logging via docker-compose
RUN mkdir /pg_logs
RUN chown postgres:postgres /pg_logs

# Add entrypoint script
ADD init-db.sh /docker-entrypoint-initdb.d/init-db.sh
RUN chmod +u /docker-entrypoint-initdb.d/init-db.sh
