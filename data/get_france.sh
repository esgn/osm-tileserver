[ -e data.osm.pbf ] && rm data.osm.pbf
wget https://download.geofabrik.de/europe/france-latest.osm.pbf
mv france-latest.osm.pbf data.osm.pbf
