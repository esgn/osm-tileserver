#!/bin/bash

#------------------------------------------------------------------------------
# Calcute ram ratios for postgresql configuration
#------------------------------------------------------------------------------

threequarter=`awk '( $1 == "MemTotal:" ) { print $2*0.75/1000 }' /proc/meminfo`
threequarter=${threequarter%.*}"MB"
onequarter=`awk '( $1 == "MemTotal:" ) { print $2*0.25/1000 }' /proc/meminfo`
onequarter=${onequarter%.*}"MB"
#fivepercent=`awk '( $1 == "MemTotal:" ) { print $2*0.05/1000 }' /proc/meminfo`
#fivepercent=${fivepercent%.*}"MB"

#------------------------------------------------------------------------------
# Apply ram ratios to postgresql configuration
#------------------------------------------------------------------------------

sed -i.bak 's/^shared_buffers =.*/shared_buffers = '$onequarter'/g' import.conf
sed -i.bak 's/^effective_cache_size =.*/effective_cache_size = '$threequarter'/g' import.conf

sed -i.bak 's/^shared_buffers =.*/shared_buffers = '$onequarter'/g' render.conf
sed -i.bak 's/^effective_cache_size =.*/effective_cache_size = '$threequarter'/g' render.conf
