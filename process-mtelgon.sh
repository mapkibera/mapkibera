#!/bin/sh

# GET fresh Mt Elgon extract from OSM
wget http://www.openstreetmap.org/api/0.6/map?bbox=34.40356,0.74961,34.83117,0.95577 -O /home/mikel/mtelgon/mtelgon.osm


#
# ROADS
#

# Road extract??
cd /home/mikel/mtelgon/shapefile; rm Road.* Railway.*; osmexport ./shp-transport.oxr /home/mikel/mtelgon/mtelgon.osm .; zip transport.zip Road.* Railway.*; rm Road.* Railway.*
cd /home/mikel/mtelgon/shapefile; rm Boundary.*;osmexport ./shp-boundary.oxr /home/mikel/mtelgon/mtelgon.osm .; zip boundary-shapefile.zip Boundary.*; rm Boundary.*

#
# POLLING PLACE
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mtelgon/mtelgon.osm" --tf accept-nodes "education:type=*" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/mtelgon/mtelgon.polling.osm"

# Convert extract to Shapefile
cd /home/mikel/mtelgon/shapefile; rm polling.*; osmexport ./shp-polling.oxr /home/mikel/mtelgon/mtelgon.polling.osm .; zip polling-shapefile.zip polling.*; rm polling.* 
