@addNewRow  = (link) ->
  new_id = new Date().getTime()
  regexp = new RegExp "new_" + $(link).attr('data-addRow-association'), "g"
  content = $(link).attr('data-addRow-content')
  table_id = $(link).attr('data-addRow-tableid')
  new_content = content.replace regexp, new_id
  row = '#' + table_id + ' tr:last';
  $(row).after(new_content);
  
  remove = row + ' a[data-removeRow]'
  $(remove).on "click", ->
    removeRow this
    return false

@removeRow = (link) ->
  $(link).prev("input[type=hidden][name$='[_destroy]']").val("true");
  $(link).parent('td').parent('tr').hide();

@MapInitializer = 
  #initialize map based on 
  initialize: (initialLocation, mapCanvasId) ->
    mapOptions = 
      zoom: 8
      center: initialLocation

    new google.maps.Map document.getElementById(mapCanvasId), mapOptions
    
    
  #initialize map based on address
  #callbackFinalize will be called on the finish of the function
  initializeByAddress: (address, mapCanvasId, callbackFinalize) ->
    geocoder = new google.maps.Geocoder()
    
    geocoder.geocode {'address' : address}, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        initialLocation = new google.maps.LatLng results[0].geometry.location.lat(), results[0].geometry.location.lng()
      else
        initialLocation = new google.maps.LatLng 0, 0;

      callbackFinalize(MapInitializer.initialize initialLocation, mapCanvasId) \
        unless callbackFinalize == undefined or !(callbackFinalize instanceof Function)

      MapInitializer.initialize initialLocation, mapCanvasId \
        if callbackFinalize == undefined or !(callbackFinalize instanceof Function)
  
  #initialize map based on defaultAddress
  #and then set center to current location if possible to determine
  #the current location
  initializeByCurrentLoc: (defaultAddress, mapCanvasId, callbackFinalize) ->
    MapInitializer.initializeByAddress defaultAddress, mapCanvasId, \
      (map) ->
        if navigator.geolocation
          navigator.geolocation.getCurrentPosition \
            (position) ->
                latLng = new google.maps.LatLng position.coords.latitude, position.coords.longitude
                map.panTo latLng
                callbackFinalize(map) \
                unless callbackFinalize == undefined or !(callbackFinalize instanceof Function)
        else
          callbackFinalize(map) \
          unless callbackFinalize == undefined or !(callbackFinalize instanceof Function)
          
$(document).ready ->
  console.log "global"
  $("a[data-addRow-association]").on "click", ->
    addNewRow this
    return false
    
  $("a[data-removeRow]").on "click", ->
    removeRow this
    return false