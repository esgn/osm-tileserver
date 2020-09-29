# What is this ?

This is a docker-compose project for testing OSM tile servers. It is aimed at doing benchmarks and test various parameters or configurations.\
As for now, it runs with the "usual suspects" ([osm2pgsql](https://github.com/openstreetmap/osm2pgsql), [mod_tile + renderd](https://github.com/openstreetmap/mod_tile), [mapnik](https://github.com/mapnik/mapnik)) using the [openstreetmap-carto](https://github.com/gravitystorm/openstreetmap-carto) style.\
Updating the database and expiring the corresponding tiles is possible via the use of the `updater` image.

To get more details about the way the different images interact with each other, have a look at the `docker-compose.yml` file.

# Deploying an OSM tile server

## #1 Download OSM data in .pbf format

You can download the full planet dump from https://planet.openstreetmap.org/ or data extracts from sites like https://download.geofabrik.de/.

Download the dataset of your choice in the `./data` folder and rename it to `data.osm.pbf`.

Some `get_country.sh` scripts are already provided in the `./data` folder to do this rapidly (e.g. `bash get_france.sh`).

## #2 Insert OSM data in PostgreSQL

### Using osm2pgsql

The osm2pgsql image :
* imports `data.osm.pbf` to database
* creates openstreetmap carto additional indexes
* `VACUUM ANALYZE` the database
* shuts down PostgreSQL after import

#### With default options

Simply run the following command 

```bash
docker-compose up -d osm2pgsql
```

A `importer_timestamp.log` file for the import will be created in the `./logs/importer` folder. 

If everything goes according to plan, all the containers will be shut down at the end of import process.

#### With custom options

Run the following command in a `screen` or detach (`run -d`)

```bash
docker-compose run osm2pgsql --database osm --slim --create --multi-geometry --hstore --cache 96000 --number-processes 10 --tag-transform-script /home/renderer/src/openstreetmap-carto/openstreetmap-carto.lua -S /home/renderer/src/openstreetmap-carto/openstreetmap-carto.style /home/renderer/data/data.osm.pbf
```

The following parameters must be adjusted to fit your host configuration : 

* `--cache num` : Use up to _num_ MB of RAM for caching nodes. 75% of the available RAM is the value applied when running with default options.
* `--number-processes ` : Specifies the number of parallel processes used for certain operations. _number of processing units available - 2_ is the value applied when running with default options.

It is possible to add the `--drop` option to speed up the import. **If you do so, please bear in mind than no further updates of the database will be possible.**

For more options see osm2pgsql [documentation](https://github.com/openstreetmap/osm2pgsql/blob/master/docs/usage.md)


### Using IMPOSM3 (not fully functional)

_Only for testing as of now. Won't work with the tile server or updater_

```bash
docker-compose run imposm3 imposm import -mapping /imposm3-example-mapping.yml -read /data/data.osm.pbf -write -connection postgis://postgis:postgis@postgis/osm
```

Some notes:
* IMPOSM3 uses its own mapping file format
* IMPOSM3 imports everything in a temporary PostgreSQL schema by default. The `deployproduction` flag must be used to import in the public schema.

## #3 Run the tile server

```bash
docker-compose up -d tile-server 
```

The server will be available on http://localhost:8888 by default. You can change port or deactivate port opening in the `docker-compose.yml` file.

## #4 Pre-render some tiles (optional)

The tile-server image contains the [render_list_geo.pl](https://github.com/alx77/render_list_geo.pl) script by default. 
This script may be used to generate tiles for different zoom levels inside a given geographic area.

Here is an example for generating tiles on a large part of France. You might want to launch this command into a `screen` session or detach as it might take quite some time.

```bash
docker-compose exec tile-server /render_list_geo.pl -z 10 -Z 14 -n 8 -m ajt -x -0.966797 -X 5.778809 -y 43.357138 -Y 49.224773
```

* `-z` is the min zoom level
* `-Z` is the max zoom level
* `-n` is the number of threads. Adjust this value depending on your hardware. The use of too many threads may trigger errors.

## #5 Keep the database up to date and expire existing tiles

In order to keep the database up to date with the OSM master database and consequently to invalidate already generated tiles,
an updater image is provided. This image uses [osmosis](https://github.com/openstreetmap/osmosis) for downloading updates, [osm2pgsql](https://github.com/openstreetmap/osm2pgsql) to import updates to the database and [render_expired](https://github.com/openstreetmap/mod_tile/blob/master/src/render_expired.c) which is part of mod_tile to expire existing tiles.

To use the updater image, simply create a container with the following command :

```bash
docker-compose up -d updater
```

A log directory will be available at `./logs/updater` containing the results of the different tasks.

By default the process of updating the database and expiring the tiles is launched every 15 minutes via a cron job.

See the source code of the image for more information.

# Testing and benchmarking

## Data import benchmarking

Data import performances are influenced by :
* osm2pgsql options
* postgresql configuration options

These options derive from the hardware available for running the process : 
* Number of CPU cores
* Amount of RAM available
* Storage hardware : SATA, SSD or NVME

As an example, an [extract](test-examples/import_uk.md) of the tests that were conducted to define the content of `images/postgis/import.conf`

## Tile generation benchmarking

The `tile-server` image contains an interesting feature for testing:
* The render_list_geo.pl script from https://github.com/alx77/render_list_geo.pl to render tiles at given zoom levels on certain geographic area

The `postgis` image also contains interesting features for testing:
* Log output can be activated by editing docker-compose.yml (see command section of postgis container in `docker-compose.yml`) and `images/postgis/import.conf` can be used to trigger logging of slow queries (see `log_min_duration_statement`)

For example, an [extract](test-examples/render_fr.md) of the tests that were done to define the content of `images/postgis/render.conf`

## Changing PostgreSQL configuration parameters

The `postgis` image uses two PostgreSQL configuration files :
* `import.conf` which contains minimal PostgreSQL parameters to perform the OSM data import
* `render.conf` which contains minimal PostgreSQL parameters to perform tile rendering

In addition, the `adapt_conf.sh` script is executed during image build to automatically adjust some options value to the available RAM on the host.

By patching the configuration files and/or the script files you can define new sets of configuration for PostgreSQL and test their impact.

However some options of PostgreSQL may also be edited directly on the live instance to avoid rebuilding image. 
The following sections explain how to edit PostgreSQL options on a live instance.

### Edit PostgreSQL options of a live instance

#### Check option value

```SQL
SHOW work_mem;
```

#### Getting context of the option

For the work_mem option as an example : 

```SQL
SELECT context FROM pg_settings WHERE name = 'work_mem';
```

One of the following context value is possible :

```SQL
      context      
-------------------
 postmaster
 superuser-backend
 user
 internal
 backend
 sighup
 superuser
```

These values gives an indication as whether it is possible to change the option value without restarting.
See https://www.postgresql.org/docs/current/view-pg-settings.html for more information about these context values. 

#### Changing configuration parameters

```SQL
ALTER SYSTEM SET work_mem = '192GB'
```

#### Reload configuration

`pg_reload_conf` sends a SIGHUP signal to the server, causing configuration files to be reloaded by all server processes.

```SQL
 SELECT * FROM pg_reload_conf();
 ```

#### Check if a restart of PostgreSQL is necessary

If you want to double-check no restart is required execute the following query.

```SQL
SELECT pending_restart FROM pg_settings WHERE name = 'work_mem';
```

# TODO list 

- [ ] Define the best rules to automatically adjust PostgreSQL options to available hardware by default
- [ ] Add flat_nodes support for osm2pgsql
- [ ] Supports different styles : OSM Bright, OSMFR, ...
- [ ] Write performance test scenarios (Jmeter or else)
- [ ] Provide better logging strategy (log rotate, etc.)
- [ ] Build a tile-server with Tirex
- [ ] Build a vector tile server
