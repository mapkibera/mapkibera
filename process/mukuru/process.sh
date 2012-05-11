#!/bin/sh

# GET fresh Mukuru extract from OSM
wget http://www.openstreetmap.org/api/0.6/map?bbox=36.8285,-1.3318,36.8971,-1.2936 -O /home/mikel/mukuru/mukuru.osm

## Tag report
/home/mikel/bin/tag_report.py /home/mikel/mukuru/mukuru.osm > /home/mikel/mukuru/tags.html

#
# ROADS/RAILWAY
#

cd /home/mikel/mukuru/shapefile; rm Road.* Railway.*; osmexport ./shp-transport.oxr /home/mikel/mukuru/mukuru.osm .; zip transport.zip Road.* Railway.*; rm Road.* Railway.*

#
# BOUNDARY
#

cd /home/mikel/mukuru/shapefile; rm Boundary.*;osmexport ./shp-boundary.oxr /home/mikel/mukuru/mukuru.osm .; zip boundary-shapefile.zip Boundary.*; rm Boundary.*

#
# HEALTH
#

# Make health extract
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --node-key-value keyValueList="amenity.pharmacy,amenity.hospital" --tf reject-ways --tf reject-relations --write-xml file="/tmp/mukuru.health.1.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --tf accept-nodes "health_facility:type=*" --tf reject-ways --tf reject-relations --write-xml file="/tmp/mukuru.health.2.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/tmp/mukuru.health.1.osm" --read-xml file="/tmp/mukuru.health.2.osm" --merge --write-xml file="/home/mikel/mukuru/mukuru.health.osm"

# Convert extract to KML
cd /home/mikel/mukuru/shapefile; osmexport ./kml-complex.oxr /home/mikel/mukuru/mukuru.osm mukuru.kml
# Convert extract to Shapefiles
cd /home/mikel/mukuru/shapefile; rm health.*; osmexport ./shp-health.oxr /home/mikel/mukuru/mukuru.health.osm .; zip health-shapefile.zip health.*; rm health.*;
# Convert extract to CSV
cd /home/mikel/mukuru/shapefile; rm health.csv; osmexport ./csv-pois.oxr /home/mikel/mukuru/mukuru.health.osm .

#
# SECURITY
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --node-key-value keyValueList="security:light.yes,security:bar.yes,security:hatari_spot.yes,security:black_spot.yes,security:other.yes,security:gbv_support.yes,security:chiefs_camp.yes,amenity.bar,amenity.pub,shop.alcohol,amenity.police" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/mukuru/mukuru.security.osm"

# Convert extract to Shapefile
cd /home/mikel/mukuru/shapefile; rm security.*; osmexport ./shp-security.oxr /home/mikel/mukuru/mukuru.security.osm .; zip security-shapefile.zip security.*; rm security.* 

#
# SCHOOLS
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --node-key-value keyValueList="amenity.school,amenity.kindergarten" --tf reject-ways --tf reject-relations --write-xml file="/tmp/mukuru.education.1.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --tf accept-nodes "education:type=*" --tf reject-ways --tf reject-relations --write-xml file="/tmp/mukuru.education.2.osm"
/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/tmp/mukuru.education.1.osm" --read-xml file="/tmp/mukuru.education.2.osm" --merge --write-xml file="/home/mikel/mukuru/mukuru.education.osm"

# Convert extract to Shapefile
cd /home/mikel/mukuru/shapefile; rm education.*; osmexport ./shp-education.oxr /home/mikel/mukuru/mukuru.education.osm .; zip education-shapefile.zip education.*; rm education.*
# Convert extract to CSV
cd /home/mikel/mukuru/shapefile; rm education.csv; osmexport ./csv-education.oxr /home/mikel/mukuru/mukuru.education.osm .

#
# WATSAN
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --node-key-value keyValueList="watsan:toilet_public.yes,watsan:toilet_private.yes,watsan:biocentre.yes,watsan:pee_point.yes,watsan:water_public.yes,watsan:water_private.yes,watsan:bathroom.yes,watsan:dumping_site.yes,watsan:recycling.yes,watsan:urban_agriculture.yes,watsan:other.yes,amenity.toilets,amenity.drinking_water,amenity.recycling,man_made.water_tower,natural.water" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/mukuru/mukuru.watsan.osm"

# Convert extract to Shapefile
cd /home/mikel/mukuru/shapefile; rm watsan.*; osmexport ./shp-watsan.oxr /home/mikel/mukuru/mukuru.watsan.osm .; zip watsan-shapefile.zip watsan.*; rm watsan.* 

#
# SECURITY
#

#
# RELIGION
#

/home/mikel/src/osmosis-0.34/bin/osmosis --read-xml file="/home/mikel/mukuru/mukuru.osm" --node-key-value keyValueList="amenity.place_of_worship" --tf reject-ways --tf reject-relations --write-xml file="/home/mikel/mukuru/mukuru.religion.osm"

# Convert extract to Shapefile
cd /home/mikel/mukuru/shapefile; rm religion.*; osmexport ./shp-religion.oxr /home/mikel/mukuru/mukuru.religion.osm .; zip religion-shapefile.zip religion.*; rm religion.* 

#
# LANDUSE
#

cd /home/mikel/mukuru/shapefile; rm landuse.*;osmexport ./shp-landuse.oxr /home/mikel/mukuru/mukuru.osm .; zip landuse-shapefile.zip landuse.*; rm landuse.*


#
# POI
#

cd /home/mikel/mukuru/shapefile; rm poi.*;osmexport ./shp-poi.oxr /home/mikel/mukuru/mukuru.osm .; zip poi-shapefile.zip poi.*; rm poi.*

#
# WATERWAY
#

cd /home/mikel/mukuru/shapefile; rm waterway.*;osmexport ./shp-waterway.oxr /home/mikel/mukuru/mukuru.osm .; zip waterway-shapefile.zip waterway.*; rm waterway.*

#
# IMAGE
#

cd /home/mikel/mukuru/; ./mkmap.pl > mukuru.png
