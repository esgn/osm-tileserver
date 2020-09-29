[ -e data.osm.pbf ] && rm data.osm.pbf
wget https://download.geofabrik.de/europe/great-britain-latest.osm.pbf
mv great-britain-latest.osm.pbf data.osm.pbf
