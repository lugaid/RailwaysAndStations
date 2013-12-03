var map;
var initialLocation;

$(document).ready(function() {
	var country = "Brazil";
	var geocoder = new google.maps.Geocoder();
	
	geocoder.geocode( {'address' : country}, function(results, status) {
	    if (status == google.maps.GeocoderStatus.OK) {
	        initialLocation = new google.maps.LatLng(results[0].geometry.location.lat(), results[0].geometry.location.lng());
	    } else {
	    	initialLocation = new google.maps.LatLng(-15.930959, -53.035355);
	    }
	    
	    //initialize 
	    initialize()
	});
});

function initialize() {
  var mapOptions = {zoom: 8,
  	                center: initialLocation};
    
  map = new google.maps.Map(document.getElementById('map_canvas'), mapOptions);
  
  //geolocalization
  if (navigator.geolocation) {
  	navigator.geolocation.getCurrentPosition(geoLocalizationSucess);
  }
}

function geoLocalizationSucess(position) {
	var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
	
	map.panTo(latLng);
}
