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
# Activate postgis and hstore extensions for the database
#------------------------------------------------------------------------------

psql -v ON_ERROR_STOP=1 -d "$POSTGRES_DB" --username "$POSTGRES_USER" <<-EOSQL
	CREATE EXTENSION IF NOT EXISTS postgis;
	CREATE EXTENSION IF NOT EXISTS hstore;
EOSQL
