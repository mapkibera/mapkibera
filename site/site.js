var lon= 36.7886; var lat= -1.315; var zoom= 14; var lonLat;var map; 
addOnloadHook( slippymap_init ); 
function slippymap_resetPosition() {	
  map.setCenter(lonLat, zoom);
}
function slippymap_openOSM() {
  document.location = "http://kibera.jsintl.maps.org/";
}
function slippymap_init() {

  OpenLayers.Layer.OSM.Kibera = OpenLayers.Class(OpenLayers.Layer.OSM, {
    initialize: function(name, options) {
        var url = [
            "http://a.tile.openstreetmap.org/${z}/${x}/${y}.png",
            "http://b.tile.openstreetmap.org/${z}/${x}/${y}.png",
            "http://c.tile.openstreetmap.org/${z}/${x}/${y}.png"
        ];
        options = OpenLayers.Util.extend({ numZoomLevels: 19 }, options);
        var newArguments = [name, url, options];
        OpenLayers.Layer.OSM.prototype.initialize.apply(this, newArguments);
    },
 
    CLASS_NAME: "OpenLayers.Layer.OSM.Kibera"
  });
  map = new OpenLayers.Map("map", { 		
    controls:[ 			
      new OpenLayers.Control.Navigation(),
      new OpenLayers.Control.PanZoom(),
      new OpenLayers.Control.Attribution()
    ],
    maxExtent: new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34), 
    maxResolution:156543.0399, 
    units:'meters',
    projection: "EPSG:900913"
  });
  
  layer = new OpenLayers.Layer.OSM.Kibera("Kibera");
  map.addLayer(layer);
  epsg4326 = new OpenLayers.Projection("EPSG:4326");
  lonLat = new OpenLayers.LonLat(lon, lat).transform( epsg4326, map.getProjectionObject());
  map.setCenter (lonLat, zoom);
        	
  scalebar = new OpenLayers.Control.ScaleBar();
  map.addControl(scalebar);

  //var resetButton = new OpenLayers.Control.Button({title: "Reset view", displayClass: "resetButton", trigger: slippymap_resetPosition}); 	
  //var panel = new OpenLayers.Control.Panel( { displayClass: "buttonsPanel"}); 
  
  var openmapButton = new OpenLayers.Control.Button({title: "Goto Map", trigger: slippymap_openOSM}); 	
  var panel = new OpenLayers.Control.Panel( { displayClass: "buttonsPanel"}); 	
  panel.addControls([openmapButton]); 	
  map.addControl(panel); 


}
