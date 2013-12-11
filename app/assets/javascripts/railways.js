//= require pick-a-color-1.1.8.min.js
//= require tinycolor-0.9.15.min.js

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
	//initialize pick color
	$(".pick-a-color").each(function () {
		$(this).pickAColor({
			allowBlank  : false,
			showHexInput: false
		});
	});
	
	//add event listener
	$(".pick-a-color").each(function () {
		$(this).on("change", function () {
			change_color(this);
		});
	});
	
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
		add_or_reuse_polyline($(this).attr('data-branchIdx'));
		
		var pointIdx = $(this).attr('data-pointIdx');
		
		var selector = "input[data-branchIdx='" + $(this).attr('data-branchIdx') + "'][data-pointIdx='" + pointIdx + "'][name$='[_destroy]']";
		var latitude = $(selector).val();
		
		//just add the point if _destroy is not setec
		if($(selector) == undefined || $(selector).val() == 'false') {
			selector = "input[data-branchIdx='" + $(this).attr('data-branchIdx') + "'][data-pointIdx='" + pointIdx + "'][name$='[latitude]']";
			var latitude = $(selector).val();
			
			selector = "input[data-branchIdx='" + $(this).attr('data-branchIdx') + "'][data-pointIdx='" + pointIdx + "'][name$='[longitude]']";
			var longitude = $(selector).val();
			
			var point = new google.maps.LatLng(latitude, longitude);
			
			currentPolyline.getPath().insertAt(currentPolyline.getPath().length, point);
			add_marker(point, pointIdx);
		}
	});
	
	stop_edit_branch();
	
	fitBounds();
}

function fitBounds() {
	if(polyLines.length > 0) {
		var bounds = new google.maps.LatLngBounds();
		
		//for each polylines 
		for(i=0; i < polyLines.length;i++) {
			if(polyLines[i].getPath().length > 0) {

				//for each pointh in the path
				for(u=0;u < polyLines[i].getPath().length;u++) {
					bounds.extend(polyLines[i].getPath().getAt(u));
				}
			}
		}

		//if the bounds was filled fit the bounds
		if(!bounds.isEmpty()) {
			map.fitBounds(bounds);
		}
	}
}

function geoLocalizationSucess(position) {
	var latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
	
	map.panTo(latLng);
}

function add_branch(link, association, content, table_id) {
	add_fields(link, association, content, table_id);
	
	//stop editing
	stop_edit_branch();
	
	//initialize pick color
	var selector = "#" + table_id + " tr:last input[name$='[color]']"; 
	$(selector).pickAColor({
		allowBlank  : false,
		showHexInput: false
	});
	
	$(selector).on("change", function () {
		change_color(this);
	});
}

function edit_branch(link, association, content) {
  	currentContent = content;
  	currentLink = link;
  	
  	var branchIdx = $(link).attr('data-branchIdx');

	add_or_reuse_polyline(branchIdx);
}

function stop_edit_branch() {
	if(currentPolyline != null) {
		//hide markers
		if(currentPolyline.markers.length > 0) {
			for(i=(currentPolyline.markers.length-1); i >= 0; i--) {
				currentPolyline.markers[i].setMap(null);
			}
		}
		
		currentPolyline = null;
	}
}

function destroy_branch(link) {
	//hide line of the table
	remove_row(link);
	
	var branchIdx = $(link).attr('data-branchIdx');
	
	//search for one polyline to the current branch
	search_by_branchIdx(branchIdx);
	
	//if found one polyline remove this polyline from form, and from array of polylines and remove markers
	if(currentPolyline  != null) {
		//remove markers
		if(currentPolyline.markers.length > 0) {
			for(i=(currentPolyline.markers.length-1); i >= 0; i--) {
				remove_marker(currentPolyline.markers[i]);
			}
		}
		
		//remove from map
		currentPolyline.setMap(null);
		
		currentPolyline = null;
		
		//remove from array of polylines
		polyLines.splice(polyLines.indexOf(currentPolyline), 1);
	}
}

function add_or_reuse_polyline(branchIdx) {
	//search for one polyline to the current branch
	search_by_branchIdx(branchIdx);
	
	//if not found one polyline for the current branch create a new one.
	if(currentPolyline  == null) {
		var polyPoints = new google.maps.MVCArray();
		
		var selector = "input[data-branchIdx='" + branchIdx + "'][name$='[color]']";
		var color = $(selector).val();

		var polyOptions = {
	        path: polyPoints,
	        strokeColor: "#" + color.toString().toUpperCase(),
	        strokeOpacity: 1,
	        strokeWeight: 3};
	        
	    currentPolyline = new google.maps.Polyline(polyOptions);
	    
	    currentPolyline.setMap(map);
	    
	    currentPolyline.branchIdx = branchIdx;
	    
	    //add marker list
	    currentPolyline.markers = new Array();
	    
	    polyLines.push(currentPolyline);
	} else {
		//show markers
		if(currentPolyline.markers.length > 0) {
			for(i=(currentPolyline.markers.length-1); i >= 0; i--) {
				currentPolyline.markers[i].setMap(map);
			}
		}
	}
}

function search_by_branchIdx(branchIdx){
	//stop editing
	stop_edit_branch();
	
	if(polyLines.length > 0) {
		for(i=0; i < polyLines.length;i++) {
			if(polyLines[i].branchIdx == branchIdx) {
				currentPolyline = polyLines[i];
			}
		}
	}
}

function addLatLng(point) {
	if(currentPolyline != null) {
		var pointIdx = new Date().getTime();
		
		//define point id
	  	var regexp = new RegExp("new_points", "g");
	  	var new_content = currentContent.replace(regexp, pointIdx);
		
	  	//append fields to form
		$(currentLink).closest('form').append(new_content);
		
    	//latitude
    	var selector = "input[data-branchIdx='" + currentPolyline.branchIdx + "'][data-pointIdx='" + pointIdx + "'][name$='[latitude]']";
    	$(selector).val(point.latLng.lat());
    	
    	//longitude
    	selector = "input[data-branchIdx='" + currentPolyline.branchIdx + "'][data-pointIdx='" + pointIdx + "'][name$='[longitude]']";
    	$(selector).val(point.latLng.lng());
		
		currentPolyline.getPath().insertAt(currentPolyline.getPath().length, point.latLng);
		add_marker(point.latLng, pointIdx);
	}
}

function add_marker(point, pointIdx) {
	var marker = new google.maps.Marker({
    	position: point,
    	map: map,
    	icon: imageNormal,
        raiseOnDrag: false,
    	draggable: true,
    	reference_polyline: currentPolyline,
    	reference_position: point,
    	reference_pointIdx: pointIdx
    });
    
    //add marker to markers list of polyline
    currentPolyline.markers.push(marker);
    
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
    	var referencePolyline = marker.reference_polyline;
    	var path = marker.reference_polyline.getPath();

    	path.setAt(path.indexOf(marker.reference_position), marker.getPosition());
    	
    	//set new position to input
    	//latitude
    	var selector = "input[data-branchIdx='" + referencePolyline.branchIdx + "'][data-pointIdx='" + marker.reference_pointIdx + "'][name$='[latitude]']";
    	$(selector).val(marker.getPosition().lat());
    	
    	//longitude
    	selector = "input[data-branchIdx='" + referencePolyline.branchIdx + "'][data-pointIdx='" + marker.reference_pointIdx + "'][name$='[longitude]']";
    	$(selector).val(marker.getPosition().lng());
    	
    	//set new reference position
    	marker.reference_position = marker.getPosition();
    });
    
    //delete point when double click
    google.maps.event.addListener(marker, "dblclick", function(){
    	remove_marker(marker);
    });
}

function remove_marker(marker) {
	var referencePolyline = marker.reference_polyline;
    var path = marker.reference_polyline.getPath();

    path.removeAt(path.indexOf(marker.reference_position));

	//set delete true to hidden _destroy field
	var selector = "input[data-branchIdx='" + referencePolyline.branchIdx + "'][data-pointIdx='" + marker.reference_pointIdx + "'][name$='[_destroy]']";
	$(selector).val(true);
	
	//remove marker from map
	marker.setMap(null);
	
	//remove marker from marker list of polyline
	marker.reference_polyline.markers.splice(marker.reference_polyline.markers.indexOf(marker), 1);
}

function change_color(color) {
   	var branchIdx = $(color).attr('data-branchIdx');
	search_by_branchIdx(branchIdx);
	
	if(currentPolyline != null) {
		var color = "#" + $(color).val().toString().toUpperCase();
		
		currentPolyline.setOptions({strokeColor: color});
	}
}
