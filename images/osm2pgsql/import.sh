#!/bin/bash

#------------------------------------------------------------------------------
# -e : Exit immediately if a pipeline (which may consist of a single simple 
# command), a list, or a compound command, exits with a non-zero status
#
# -x :  After expanding each simple command, for command, case command, 
# select command, or arithmetic for command, display the expanded value of PS4, 
# followed by the command and its expanded arguments or associated word list.
#------------------------------------------------------------------------------

set -ex

#------------------------------------------------------------------------------
# Script variables
#------------------------------------------------------------------------------

T1=$(date "+%s")
TIMESTAMP=$(date -d @$T1 '+%d-%m-%Y_%Hh%Mm%Ss')
IMPORTLOG="/var/log/importer/importer_"$TIMESTAMP".log"

# get passed parameters if they exist
CMD="$@"
echo $CMD

# get current machine parameters
F=`awk '( $1 == "MemTotal:" ) { print $2*0.75/1000 }' /proc/meminfo`
CACHE=${F%.*}
PROCESSES=$((`nproc`-2))

# If no passed parameters we build them
if [ -z "$CMD" ]
then
  CMD="-d "$PGDATABASE" -s -c -G -k -C "$CACHE" --number-processes "$PROCESSES" --tag-transform-script /home/renderer/src/openstreetmap-carto/openstreetmap-carto.lua -S /home/renderer/src/openstreetmap-carto/openstreetmap-carto.style /home/renderer/data/data.osm.pbf"
fi

#------------------------------------------------------------------------------
# Wait for postgresql availability before starting OSM data import
#------------------------------------------------------------------------------

until PGPASSWORD=$PGPASSWORD psql -h "$PGHOST" -U "$PGUSER" -c '\q'
do
  >&2 echo "Postgres is unavailable - sleeping - this could take a while"
  sleep 5
done

#------------------------------------------------------------------------------
# Data import
# 1. Execute osm2pgsql command
# 2. Create indexes for OSM carto style
# 3. VACUUM ANALYZE created database
# 4. Shutdown the dbms
#------------------------------------------------------------------------------

osm2pgsql $CMD >> $IMPORTLOG 2>&1

PGPASSWORD=$PGPASSWORD psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" < /home/renderer/src/openstreetmap-carto/indexes.sql >> $IMPORTLOG 2>&1

PGPASSWORD=$PGPASSWORD psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c 'VACUUM ANALYZE' >> $IMPORTLOG 2>&1

docker exec --user postgres $PGCONTAINER pg_ctl -t 600 stop >> $IMPORTLOG 2>&1

#-------------------------------------------------------------------------------
#
# Summarize complete elapsed time
#
#-------------------------------------------------------------------------------

T2=$(date "+%s")
TIMESTAMP=$(date -d @$T2 '+%d-%m-%Y_%Hh%Mm%Ss')
echo "End of import at "$TIMESTAMP
echo "Elapsed time for import : "$(($T2-T1))" seconds"
