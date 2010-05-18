var map;
var mapBounds = new OpenLayers.Bounds( 36.7545581344, -1.3439474203, 36.8184242591, -1.27943069886);
var mapMinZoom = 15;
var mapMaxZoom = 19;
			    
var images = new Array();
var layers = new Array();
var gml;
          
// avoid pink tiles
OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
OpenLayers.Util.onImageLoadErrorColor = "transparent";


function mD(e) {
  var originalElement = e.srcElement || e.originalTarget;
  var href = originalElement.href;
  if (originalElement.nodeName == "A" && href.match("http://www.openstreetmap.org/browse/")) {
    href = href.replace('http://www.openstreetmap.org/browse/','http://www.openstreetmap.org/api/0.6/');
	           
    if (gml) { map.removeLayer(gml); } //$("status").innerHTML = 'loading'; }

    gml = new OpenLayers.Layer.GML("OSM", href, {format: OpenLayers.Format.OSM});
    map.addLayer(gml);
    gml.preFeatureInsert = style_osm_feature; 
    var sf = new OpenLayers.Control.SelectFeature(gml, {'onSelect': on_feature_hover});
    map.addControl(sf);
    sf.activate();
    return false;
  }
} 

function init(images_arg){
  document.onclick = mD;
  if (document.layers) document.captureEvents(Event.KEYPRESS || Event.CLICK);

  OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url=";

  images = images_arg.split(',');
//	var options = {
//	  controls: [],
//	  projection: new OpenLayers.Projection("EPSG:900913"),
//	  displayProjection: new OpenLayers.Projection("EPSG:4326"),
//	  units: "m",
//	  maxResolution: 156543.0339,
//	  maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
//	};
//  map = new OpenLayers.Map('map', options);

//  var osm = new OpenLayers.Layer.TMS( "OpenStreetMap",
//	  "http://tile.openstreetmap.org/",
//	  { type: 'png', getURL: osm_getTileURL, displayOutsideMaxExtent: true, attribution: '<a href="http://www.openstreetmap.org/">OpenStreetMap</a>', numZoomLevels:20} );
//  map.addLayer(osm);

  OpenLayers.Layer.OSM.Kibera = OpenLayers.Class(OpenLayers.Layer.OSM, {
    initialize: function(name, options) {
        var url = [
            "http://a.tile.openstreetmap.org/osm_tiles2/${z}/${x}/${y}.png"
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
    ]
  });
  
  osm = new OpenLayers.Layer.OSM.Kibera("Kibera");
  map.addLayer(osm);
            
  for (var i=0; i<images.length; i++) {
    layers[ images[i] ] = new OpenLayers.Layer.TMS( images[i],'http://aerial.maps.jsintl.org/tilecache/tilecache.cgi/1.0.0/' + images[i] + '/', { type: 'png', getURL: osm_getTileURL, numZoomLevels:20, isBaseLayer: false, opacity: 1.0} );
    map.addLayer(layers[ images[i] ]);
  }  
	
  var switcherControl = new OpenLayers.Control.LayerSwitcher();
  map.addControl(switcherControl);
  switcherControl.maximizeControl();

  //map.zoomToExtent( mapBounds.transform(map.displayProjection, map.projection ) );
  map.panTo(new OpenLayers.LonLat(-1.31016, 36.78583));
  map.zoomto(17);

	map.addControl(new OpenLayers.Control.PanZoomBar());
	map.addControl(new OpenLayers.Control.MousePosition());
	map.addControl(new OpenLayers.Control.MouseDefaults());
	map.addControl(new OpenLayers.Control.KeyboardDefaults());
}

function osm_getTileURL(bounds) {
	var res = this.map.getResolution();
	var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
	var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
	var z = this.map.getZoom();
	var limit = Math.pow(2, z);

	if (y < 0 || y >= limit) {
	  return "http://www.maptiler.org/img/none.png";
	} else {
	  x = ((x % limit) + limit) % limit;
	  return this.url + z + "/" + x + "/" + y + "." + this.type;
	}
}

function changeOpacity() {
  var newOpacity = parseFloat(OpenLayers.Util.getElement('opacity').value);
  newOpacity = Math.min(1.0, Math.max(0.1, newOpacity));
  OpenLayers.Util.getElement('opacity').value = newOpacity;
  for (var i=0; i<images.length; i++) {
    layers[images[i]].setOpacity(newOpacity);
  }
}

var currentVisibleId;
function toggle(id) {
  var element;
  if (currentVisibleId != id && currentVisibleId != null) {
    element = OpenLayers.Util.getElement(currentVisibleId);
    element.style.visibility = "hidden";
    element.style.display = "none";
  }
  element = OpenLayers.Util.getElement(id);
  if (element.style.visibility == "visible") {
    element.style.visibility = "hidden";
    element.style.display = "none";
    currentVisibleId = null;
  } else {  
    element.style.visibility = "visible";
    element.style.display = "block";
    currentVisibleId = id;
  }
}
 
function style_osm_feature(feature) {
  feature.style = OpenLayers.Util.extend({'fill':'black'}, OpenLayers.Feature.Vector.style['default']);
}
function on_feature_hover(feature) {
  var text = "<a href='http://www.openstreetmap.org/browse/node/" + feature.id +"'>Feature in OSM</a>";
  text +="<ul>";
  var type ="way";
  if (feature.geometry.CLASS_NAME == "OpenLayers.Geometry.Point") {
    type = "node";
  }    
  //text += "<li>" + feature.osm_id + ": <a href='http://crschmidt.net/osm/attributes.html?type="+type+"&id="+feature.osm_id+"'>Edit</a>, <a href='http://www.openstreetmap.org/api/0.5/"+type + "/" + feature.osm_id + "'>API</a></li>";
  for (var key in feature.attributes) {
    text += "<li>" + key + ": " + feature.attributes[key] + "</li>";
  }
  text += "</ul>";
  //$("status").innerHTML = text;
}  


