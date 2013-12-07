var map;
var initialLocation;
var polyLines = new Array();
var markers = new Array();
var currentPolyline = null;
var listener;
var currentContent;
var currentLink;

var imageNormal = new google.maps.MarkerImage(
	"/assets/square.png",
	new google.maps.Size(11, 11),
	new google.maps.Point(0, 0),
	new google.maps.Point(6, 6)
);

var imageHover = new google.maps.MarkerImage(
	"/assets/square_over.png",
	new google.maps.Size(11, 11),
	new google.maps.Point(0, 0),
	new google.maps.Point(6, 6)
);

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
	    initialize();
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
  
  listener = google.maps.event.addListener(map, 'click', addLatLng);
  
  //initialize polylines for editing model
  initializePolylines();
}

function initializePolylines() {
	$("input[name*='[points_attributes]'][name$='[id]']").each(function(){
		add_or_reuse_branch($(this).attr('data-branchId'));
		
		var pointId = $(this).attr('data-pointId');
		
		console.log($(this));
		
		var selector = "input[data-branchId='" + $(this).attr('data-branchId') + "'][data-pointId='" + pointId + "'][name$='[latitude]']";
		var latitude = $(selector).val();
		
		selector = "input[data-branchId='" + $(this).attr('data-branchId') + "'][data-pointId='" + pointId + "'][name$='[longitude]']";
		var longitude = $(selector).val();
		
		var point = new google.maps.LatLng(latitude, longitude);
		
		
		
		console.log($(this).attr('data-branchId'));
		console.log(latitude);
		console.log(longitude);
		console.log(pointId);
		console.log(currentPolyline.getPath());
		console.log(point);
		
		currentPolyline.getPath().insertAt(currentPolyline.getPath().length, point);
		addMarker(point, pointId);
		
		console.log(currentPolyline.getPath().length);
	});
	
	currentPolyline = null;
}

function geoLocalizationSucess(position) {
	var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
	
	map.panTo(latLng);
}

function edit_branch(link, association, content) {
  	currentContent = content;
  	currentLink = link;
  	
  	var branchId = new Date().getTime();
  	
	if($(link).attr('data-branchId') == undefined) {
		$(link).attr('data-branchId', branchId);
	} else {
		branchId = $(link).attr('data-branchId');
	}
	
	add_or_reuse_branch(branchId);
}

function add_or_reuse_branch(branchId) {
	currentPolyline  = null;
	  	
	if(polyLines.length > 0) {
		for(i=0; i < polyLines.length;i++) {
			if(polyLines[i].branchId == branchId) {
				currentPolyline = polyLines[i];
			}
		}
	}
	
	if(currentPolyline  == null) {
		var polyPoints = new google.maps.MVCArray();
		
		var polyOptions = {
	        path: polyPoints,
	        strokeColor: "#FF0000",
	        strokeOpacity: 1,
	        strokeWeight: 3};
	        
	    currentPolyline = new google.maps.Polyline(polyOptions);
	    
	    currentPolyline.setMap(map);
	    
	    currentPolyline.branchId = branchId;
	    
	    polyLines.push(currentPolyline);
	}
}

function addLatLng(point) {
	if(currentPolyline != null) {
		var pointId = new Date().getTime();
		
		//define point id
	  	var regexp = new RegExp("new_points", "g");
	  	var new_content = currentContent.replace(regexp, pointId);
	  	
	  	//define latitude
	  	regexp = new RegExp("new_latitude", "g");
	  	new_content = new_content.replace(regexp, point.latLng.pb);
	  	
	  	//define longitude
	  	regexp = new RegExp("new_longitude", "g");
	  	new_content = new_content.replace(regexp, point.latLng.qb);
		
	  	//append fields to form
		$(currentLink).closest('form').append(new_content);
		
		currentPolyline.getPath().insertAt(currentPolyline.getPath().length, point.latLng);
		addMarker(point.latLng, pointId);
	}
}

function addMarker(point, pointId) {
	var marker = new google.maps.Marker({
    	position: point,
    	map: map,
    	icon: imageNormal,
        raiseOnDrag: false,
    	draggable: true,
    	reference_polyline: currentPolyline,
    	reference_position: point,
    	reference_pointId: pointId
    });
    
    //change icon when mouse over
    google.maps.event.addListener(marker, "mouseover", function() {
    	marker.setIcon(imageHover);
    });
    
    //change icon when mouse out
    google.maps.event.addListener(marker, "mouseout", function() {
    	marker.setIcon(imageNormal);
    });
    
    //change polyline when drag the marker
    google.maps.event.addListener(marker, "drag", function() {
    	var path = marker.reference_polyline.getPath();

    	path.setAt(path.indexOf(marker.reference_position), marker.getPosition());
    	
    	//set new position to input
    	//latitude
    	var selector = "input[data-pointId='" + marker.reference_pointId + "'][name$='[latitude]']";
    	$(selector).val(marker.getPosition().pb);
    	
    	//longitude
    	selector = "input[data-pointId='" + marker.reference_pointId + "'][name$='[longitude]']";
    	$(selector).val(marker.getPosition().qb);
    	
    	//set new reference position
    	marker.reference_position = marker.getPosition();
    });
    
    //delete point when double click
    google.maps.event.addListener(marker, "dblclick", function() {
    	var path = marker.reference_polyline.getPath();

    	path.removeAt(path.indexOf(marker.reference_position));
    	
    	marker.setMap(null);
    });
}
