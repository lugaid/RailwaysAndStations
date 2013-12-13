#= require pick-a-color-1.1.8.min.js
#= require tinycolor-0.9.15.min.js
map = undefined
polyLines = new Array
currentEditingPolyLine = undefined
currentEditingPointContent = undefined
currentEditingAssociation = undefined
currentEditingLink = undefined

imageNormal = new google.maps.MarkerImage \
  "/assets/square.png", \
  new google.maps.Size(11, 11), \
  new google.maps.Point(0, 0), \
  new google.maps.Point(6, 6)

imageHover = new google.maps.MarkerImage \
  "/assets/square_over.png", \
  new google.maps.Size(11, 11), \
  new google.maps.Point(0, 0), \
  new google.maps.Point(6, 6)

finishMapInitialize = (map) ->
  @map = map
  
  initializePolylines()
  
  google.maps.event.addListener @map, 'click', addPoint
  
initializePolylines = ->
  $("input[name*='[points_attributes]'][name$='[id]']").each ->
    polyLine = addOrReusePolyline $(this).attr 'data-branchIdx'
    
    branchIdx = $(this).attr 'data-branchIdx'
    pointIdx = $(this).attr 'data-pointIdx'
    
    if $(selector) != undefined and $(selector).val() != 'false'
      selector = "input[data-branchIdx='" + branchIdx + "'][data-pointIdx='" + pointIdx + "'][name$='[latitude]']"
      latitude = $(selector).val()
      
      selector = "input[data-branchIdx='" + branchIdx + "'][data-pointIdx='" + pointIdx + "'][name$='[longitude]']"
      longitude = $(selector).val()
      
      point = new google.maps.LatLng latitude, longitude
      
      polyLine.getPath().insertAt polyLine.getPath().length, point
      
      addMarker polyLine, point, pointIdx

addPoint = (point) ->
  w = window
  #change current scope
  if w.currentEditingPolyLine != undefined
    pointIdx = new Date().getTime();
    branchIdx = w.currentEditingPolyLine.branchIdx
    
    #define point id
    regexp = new RegExp "new_" + w.currentEditingAssociation, "g"
    new_content = w.currentEditingPointContent.replace regexp, pointIdx
    
    #append fields to form
    $(w.currentEditingLink).closest('form').append new_content
    
    #latitude
    selector = "input[data-branchIdx='" + branchIdx + "'][data-pointIdx='" + pointIdx + "'][name$='[latitude]']"
    $(selector).val point.latLng.lat()
      
    #longitude
    selector = "input[data-branchIdx='" + branchIdx + "'][data-pointIdx='" + pointIdx + "'][name$='[longitude]']"
    $(selector).val point.latLng.lng()
    
    w.currentEditingPolyLine.getPath().insertAt w.currentEditingPolyLine.getPath().length, point.latLng
    marker = addMarker w.currentEditingPolyLine, point.latLng, pointIdx
    marker.setMap w.map
  
addOrReusePolyline = (branchIdx) ->
  polyLine = searchPolylineByBranchIdx branchIdx

  #if not fount one polyline create a new one
  if polyLine == undefined
    selector = "input[data-branchIdx='" + branchIdx + "'][name$='[color]']"
    
    polyOptions =
      path: new google.maps.MVCArray
      strokeColor: "#" + $(selector).val().toString().toUpperCase()
      strokeOpacity: 1
      strokeWeight: 3
      
    polyLine = new google.maps.Polyline polyOptions;
    
    polyLine.setMap @map
    
    polyLine.branchIdx = branchIdx
      
    #add marker list
    polyLine.markers = new Array

    polyLines.push polyLine;
    
  return polyLine
  
searchPolylineByBranchIdx = (branchIdx) ->
  for polyLine in polyLines
    if polyLine.branchIdx == branchIdx
      return polyLine
      
  return undefined

addMarker = (polyLine, point, pointIdx) ->
  marker = new google.maps.Marker
      position: point
      icon: imageNormal
      raiseOnDrag: false
      draggable: true
      reference_polyline: polyLine
      reference_position: point
      reference_pointIdx: pointIdx
    
  #add marker to markers list of polyline
  polyLine.markers.push marker
    
  #change icon when mouse over
  google.maps.event.addListener marker, "mouseover", ->
    marker.setIcon imageHover
    
  #change icon when mouse out
  google.maps.event.addListener marker, "mouseout", ->
    marker.setIcon imageNormal
    
  #change polyline when drag the marker
  google.maps.event.addListener marker, "drag", ->
    referencePolyline = marker.reference_polyline
    path = marker.reference_polyline.getPath()

    path.setAt(path.indexOf(marker.reference_position), marker.getPosition())
      
    #set new position to input
    #latitude
    selector = "input[data-branchIdx='" + referencePolyline.branchIdx + "'][data-pointIdx='" + marker.reference_pointIdx + "'][name$='[latitude]']"
    $(selector).val marker.getPosition().lat()
      
    #longitude
    selector = "input[data-branchIdx='" + referencePolyline.branchIdx + "'][data-pointIdx='" + marker.reference_pointIdx + "'][name$='[longitude]']"
    $(selector).val marker.getPosition().lng()
      
    #set new reference position
    marker.reference_position = marker.getPosition()
    
  #delete point when double click
  google.maps.event.addListener marker, "dblclick", ->
    removeMarker marker
  
  return marker

removeMarker = (marker) ->
  referencePolyline = marker.reference_polyline
  path = marker.reference_polyline.getPath()

  path.removeAt path.indexOf(marker.reference_position)

  #set delete true to hidden _destroy field
  selector = "input[data-branchIdx='" + referencePolyline.branchIdx + "'][data-pointIdx='" + marker.reference_pointIdx + "'][name$='[_destroy]']"
  $(selector).val true
  
  #remove marker from map
  marker.setMap null
  
  #remove marker from marker list of polyline
  marker.reference_polyline.markers.splice marker.reference_polyline.markers.indexOf(marker), 1

changeColor = (color) ->
  branchIdx = $(color).attr 'data-branchIdx'

  polyLine = addOrReusePolyline branchIdx
  
  color = "#" + $(color).val().toString().toUpperCase()
    
  polyLine.setOptions
    strokeColor: color
  
addBranch = (link) ->
  table_id = $(link).attr('data-addRow-tableid')
  
  selector = "#" + table_id + " tr:last input[name$='[color]']"
  $(selector).pickAColor
    allowBlank  : false
    showHexInput: false

  $(selector).on "change", ->
    changeColor this
  
  selector = "#" + table_id + " tr:last a[data-editBranchTrack-association]"
  $(selector).on "click", ->
      editBranch this
      return false
  
  selector = "#" + table_id + " tr:last a[data-removeRow]"
  $(selector).on "click", ->
    destroyBranch this
    return false
      
editBranch = (link) ->
  stopEditBranch()
  branchIdx = $(link).attr 'data-branchIdx'

  @currentEditingPointContent = $(link).attr 'data-editBranchTrack-pointContent'
  @currentEditingAssociation = $(link).attr 'data-editBranchTrack-association'
  @currentEditingLink = link
  
  #set editing polyline
  @currentEditingPolyLine = addOrReusePolyline branchIdx
  
  console.log @currentEditingPolyLine
  #show markers on map
  for marker in @currentEditingPolyLine.markers
    marker.setMap @map
  
stopEditBranch = ->
  if @currentEditingPolyLine != undefined
    #hide markers on map
    for marker in @currentEditingPolyLine.markers
      marker.setMap null
      
    @currentEditingPolyLine = undefined
    @currentEditingPointContent = undefined
    @currentEditingAssociation = undefined
    @currentEditingLink = undefined

destroyBranch = (link) ->
  branchIdx = $(link).attr 'data-branchIdx'
  
  polyline = searchPolylineByBranchIdx branchIdx
  
  if polyline != undefined
    #stop editing if current editing is the destroyed branch
    stopEditBranch() if polyline == @currentEditingPolyLine
    
    #remove markers
    count = polyline.markers.length - 1
    for i in [count...0] by -1
      removeMarker polyline.markers[i]
      
    #hide polyline
    polyline.setMap null
    
    #remove polyline from array
    polyLines.splice polyLines.indexOf(polyline), 1

  
$(document).ready ->
  MapInitializer.initializeByCurrentLoc "Brazil", "map_canvas", finishMapInitialize

  $(".pick-a-color").each ->
    $(this).pickAColor
      allowBlank  : false
      showHexInput: false

    $(this).on "change", ->
      changeColor this
      
  $("a[data-editBranchTrack-association]").each ->
    $(this).on "click", ->
      editBranch this
      return false
      
  $("a[data-removeRow]").each ->
    $(this).on "click", ->
      destroyBranch this
      return false
      
  $("a[data-addRow-association]").on "click", ->
    addBranch this
    return false