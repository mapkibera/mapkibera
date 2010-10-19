#!/bin/sh

# GET fresh Mukuru extract from OSM
wget http://www.openstreetmap.org/api/0.6/map?bbox=36.85878,-1.32674,36.898,-1.29695 -O /home/mikel/mukuru/mukuru.osm

#KML
cd /home/mikel/mukuru/shapefile; osmexport /home/mikel/src/osm2shp/kml-complex.oxr /home/mikel/mukuru/mukuru.osm mukuru.kml

