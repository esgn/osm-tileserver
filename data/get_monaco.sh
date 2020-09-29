[ -e data.osm.pbf ] && rm data.osm.pbf
wget https://download.geofabrik.de/europe/monaco-latest.osm.pbf
mv monaco-latest.osm.pbf data.osm.pbf
