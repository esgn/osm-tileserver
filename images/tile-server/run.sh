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
# Configure renderd threads
# Seen in https://github.com/openstreetmap/chef/blob/d1b835abf6c54e768ead54dd0056011554ba0b71/cookbooks/tile/templates/default/renderd.conf.erb :  <%= node[:cpu][:total] - 2 %>
#------------------------------------------------------------------------------

THREADS=$((`nproc`-2))
sed -i -E "s/num_threads=[0-9]+/num_threads=${THREADS:-4}/g" /usr/local/etc/renderd.conf

#------------------------------------------------------------------------------
# Start apache
#------------------------------------------------------------------------------

service apache2 restart

#------------------------------------------------------------------------------
# Start renderd and handle termination by docker SIGTERM
#------------------------------------------------------------------------------

stop_handler() {
    kill -TERM "$child"
}
trap stop_handler SIGTERM

sudo -u renderer renderd -f -c /usr/local/etc/renderd.conf & child=$!
wait "$child"
