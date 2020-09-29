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

BASE_DIR=/var/lib/mod_tile
LOG_DIR=/var/log/updater

LOCK_FILE=/tmp/osm-update-lock.txt
CHANGES_FILE=changes.osc.gz
EXPIRY_FILE=dirty_tiles

OSMOSISLOG=$LOG_DIR/osmosis.log
OSM2PGSQLLOG=$LOG_DIR/osm2pgsql.log
EXPIRYLOG=$LOG_DIR/expiry.log
RUNLOG=$LOG_DIR/run.log

# get current machine parameters for osm2pgsql command line options
F=`awk '( $1 == "MemTotal:" ) { print $2*0.5/1000 }' /proc/meminfo`
CACHE=${F%.*}
PROCESSES=$((`nproc`-2))

#------------------------------------------------------------------------------
# The tile expiry section below can re-render, delete or dirty expired tiles.
# By default, tiles between EXPIRY_MINZOOM and EXPIRY_MAXZOOM are rerendered.
# "render_expired" can optionally delete (and/or dirty) tiles above a certail
# threshold rather than rendering them.
# Here we expire (but don't immediately rerender) tiles between zoom levels
# 13 and 18 and delete between 19 and 20.
#------------------------------------------------------------------------------

EXPIRY_MINZOOM=13
EXPIRY_MAXZOOM=20
EXPIRY_TOUCHFROM=13
EXPIRY_DELETEFROM=19

#------------------------------------------------------------------------------
# Some functions to log, handle errors and manage lock file
#------------------------------------------------------------------------------

# Log a simple info line
log_info()
{
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ $1" >> "$RUNLOG"
}

# If an error occurs set everything back to previous state
on_error()
{
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ [error] $1" >> "$RUNLOG"

    # reset to previous state
    /bin/cp $WORKOSM_DIR/state.txt.previous $WORKOSM_DIR/state.txt || true
    rm "$CHANGES_FILE" || true
    rm "$EXPIRY_FILE.$$" || true
    rm "$LOCK_FILE"
    exit
}

# Create lock if no lock exists
create_lock()
{
    # If lock file exists
    if [ -s $1 ]; then
	# verify if process id contained in lock file is still running
        if [ "$(ps -p `cat $1` | wc -l)" -gt 1 ]; then
            # if the process is still running exit with value 1
            return 1
        fi
    fi

    # Create lock file and put current process id inside the file
    echo $$ >"$1"
    # Return 0
    return 0 #true
}

# Remove lock file and changes file
free_lock()
{
    # delete filename passed as parameter
    rm "$LOCK_FILE"
    # delete changes file as everything is fully done
    rm "$CHANGES_FILE"
}

#------------------------------------------------------------------------------
# Main part of the script
#------------------------------------------------------------------------------

# Get inside Osmosis workdir
cd $WORKDIR_OSMOSIS

# On first launch (no configuration.txt) initialize the wordkir with configuration.txt and get state.txt
if [ ! -f "configuration.txt" ]
then
    timestamp=$(osmconvert /data/data.osm.pbf --out-timestamp)
    osmosis --read-replication-interval-init workingDirectory=$WORKDIR_OSMOSIS
    wget "https://replicate-sequences.osm.mazdermind.de/?$timestamp&stream=minute" -O state.txt
fi

# Try and acquire lock
if ! create_lock "$LOCK_FILE" 
then
    log_info "pid `cat $LOCK_FILE` still running"
    exit 3
fi

# get sequence number
seq=`cat state.txt | grep sequenceNumber | cut -d= -f2`
log_info "start import from seq-nr $seq"

# Keep original state file in case rollback is needed (on_error)
/bin/cp state.txt state.txt.previous

# Downloading diff with osmosis
log_info "Download changes"
if ! osmosis --read-replication-interval workingDirectory=$WORKDIR_OSMOSIS --simplify-change --write-xml-change $CHANGES_FILE 1>&2 2> "$OSMOSISLOG"
then
    on_error "Osmosis error for seq-nr $seq"
fi

# Importing changes with osm2pgsql
log_info "Importing changes"
if ! osm2pgsql --append --slim -C $CACHE --number-processes $PROCESSES -e$EXPIRY_MINZOOM-$EXPIRY_MAXZOOM -o "$EXPIRY_FILE.$$" $CHANGES_FILE 1>&2 2> "$OSM2PGSQLLOG"
then
    on_error "Osm2pgsql error for seq-nr $seq"
fi

# Invalidating existing tiles
log_info "Expiring tiles"
if ! render_expired --min-zoom=$EXPIRY_MINZOOM --touch-from=$EXPIRY_TOUCHFROM --delete-from=$EXPIRY_DELETEFROM --max-zoom=$EXPIRY_MAXZOOM -n4 < "$EXPIRY_FILE.$$"  1>&2 2> $EXPIRYLOG
then 
    on_error "render_expired error for seq-nr $seq"
fi

rm "$EXPIRY_FILE.$$"

free_lock

log_info "All done for seq-rn $seq"
