#!/bin/sh

# GET fresh Kibera extract from OSM
wget http://www.openstreetmap.org/api/0.6/map?bbox=36.7709,-1.3215,36.8069,-1.3048 -O /home/mikel/kibera/kibera.osm

cd /home/mikel/src/osm2pgsql; su postgres -c "/home/mikel/src/osm2pgsql/osm2pgsql -m /home/mikel/src/planet/planet.osm -P 5433 -d mapnik"

#touch /var/lib/mod_tile/default/planet-import-complete
rm -rf /var/lib/mod_tile/kibera/
mkdir /var/lib/mod_tile/kibera/
rm -rf /var/lib/mod_tile/kibera_health_tiles/
mkdir /var/lib/mod_tile/kibera_health_tiles/

# Load OSM into postgres, and clear tiles
cd /home/mikel/src/osm2pgsql; su postgres -c "/home/mikel/src/osm2pgsql/osm2pgsql -m /home/mikel/kibera/kibera.osm -P 5433 -d kibera"
rm -rf /var/lib/mod_tile/kibera/
mkdir /var/lib/mod_tile/kibera/

# Tag report
/home/sderle/report/tag_report.py /home/mikel/kibera/kibera.osm > /home/mikel/kibera/tags.html

#
# ROADS
#

# Road extract??
cd /home/mikel/kibera/shapefile; rm Road.* Railway.*; osmexport ./shp-transport.oxr /home/mikel/kibera/kibera.osm .; zip transport.zip Road.* Railway.*; rm Road.* Railway.*
cd /home/mikel/kibera/shapefile; rm Boundary.*;osmexport ./shp-boundary.oxr /home/mikel/kibera/kibera.osm .; zip boundary-shapefile.zip Boundary.*; rm Boundary.*

#
# HEALTH
#

# Make health extract
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --node-key-value keyValueList="amenity.pharmacy,amenity.hospital" --tf reject-ways --tf reject-relations --write-xml file="/tmp/kibera.health.1.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --tf accept-nodes "health_facility:type=*" --tf reject-ways --tf reject-relations --write-xml file="/tmp/kibera.health.2.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/tmp/kibera.health.1.osm" --read-xml file="/tmp/kibera.health.2.osm" --merge --write-xml file="/home/mikel/kibera/kibera.health.osm"

# Convert extract to KML
cd /home/mikel/kibera/shapefile; osmexport /home/mikel/src/osm2shp/kml-complex.oxr /home/mikel/kibera/kibera.osm kibera.kml
# Convert extract to Shapefiles
cd /home/mikel/kibera/shapefile; rm health.*; osmexport ./shp-health.oxr /home/mikel/kibera/kibera.health.osm .; zip health-shapefile.zip health.*; rm health.*;
# Convert extract to CSV
cd /home/mikel/kibera/shapefile; rm health.csv; osmexport ./csv-pois.oxr /home/mikel/kibera/kibera.health.osm .

#
# SECURITY
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --node-key-value keyValueList="security:light.yes,security:bar.yes,security:hatari_spot.yes,security:black_spot.yes,security:other.yes,security:gbv_support.yes,security:chiefs_camp.yes,amenity.bar,amenity.pub,shop.alcohol,amenity.police" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/kibera/kibera.security.osm"

# Convert extract to Shapefile
cd /home/mikel/kibera/shapefile; rm security.*; osmexport ./shp-security.oxr /home/mikel/kibera/kibera.security.osm .; zip security-shapefile.zip security.*; rm security.* 

#
# SCHOOLS
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --node-key-value keyValueList="amenity.school,amenity.kindergarten" --tf reject-ways --tf reject-relations --write-xml file="/tmp/kibera.education.1.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --tf accept-nodes "education:type=*" --tf reject-ways --tf reject-relations --write-xml file="/tmp/kibera.education.2.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/tmp/kibera.education.1.osm" --read-xml file="/tmp/kibera.education.2.osm" --merge --write-xml file="/home/mikel/kibera/kibera.education.osm"

# Convert extract to Shapefile
cd /home/mikel/kibera/shapefile; rm education.*; osmexport ./shp-education.oxr /home/mikel/kibera/kibera.education.osm .; zip education-shapefile.zip education.*; rm education.*
# Convert extract to CSV
cd /home/mikel/kibera/shapefile; rm education.csv; osmexport ./csv-education.oxr /home/mikel/kibera/kibera.education.osm .

#
# WATSAN
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --node-key-value keyValueList="watsan:toilet_public.yes,watsan:toilet_private.yes,watsan:pee_point.yes,watsan:water_public.yes,watsan:water_private.yes,watsan:bathroom.yes,watsan:dumping_site.yes,watsan:recycling.yes,watsan:urban_agriculture.yes,watsan:other.yes,amenity.toilets,amenity.drinking_water,amenity.recycling,man_made.water_tower,natural.water" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/kibera/kibera.watsan.osm"

# Convert extract to Shapefile
cd /home/mikel/kibera/shapefile; rm watsan.*; osmexport ./shp-watsan.oxr /home/mikel/kibera/kibera.watsan.osm .; zip watsan-shapefile.zip watsan.*; rm watsan.* 

#
# SECURITY
#

#
# RELIGION
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/kibera/kibera.osm" --node-key-value keyValueList="amenity.place_of_worship" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/kibera/kibera.religion.osm"

# Convert extract to Shapefile
cd /home/mikel/kibera/shapefile; rm religion.*; osmexport ./shp-religion.oxr /home/mikel/kibera/kibera.religion.osm .; zip religion-shapefile.zip religion.*; rm religion.* 

#
# IMAGE
#

cd /home/mikel/kibera/; ./mkmap.pl > kibera.png
