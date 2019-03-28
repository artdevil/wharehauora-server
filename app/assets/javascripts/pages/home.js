function initMap() {
  var map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: -41.743449, lng: 172.901472},
    zoom: 5,
    mapTypeId: 'roadmap'
  });

  var icon = {
    url: 'https://maps.gstatic.com/mapfiles/place_api/icons/geocode-71.png',
    size: new google.maps.Size(71, 71),
    origin: new google.maps.Point(0, 0),
    anchor: new google.maps.Point(17, 34),
    scaledSize: new google.maps.Size(25, 25)
  };

  // Create the search box and link it to the UI element.
  var input = document.getElementById('pac-input');
  var searchBox = new google.maps.places.SearchBox(input);

  var markers = [];
  var address = document.getElementById('home_address');
  var city = document.getElementById('home_city');
  var suburb = document.getElementById('home_suburb');
  var latitude = document.getElementById('home_latitude');
  var longitude = document.getElementById('home_longitude');

  // set default map if already present latitude longitude
  if(latitude.value.length > 0 && longitude.value.length > 0) {
    addMarker({ lat: parseFloat(latitude.value), lng: parseFloat(longitude.value) })
  }

  // Bias the SearchBox results towards current map's viewport.
  map.addListener('bounds_changed', function() {
    searchBox.setBounds(map.getBounds());
  });

  // Listen for the event fired when the user selects a prediction and retrieve
  // more details for that place.
  searchBox.addListener('places_changed', function() {
    var places = searchBox.getPlaces();

    if (places.length == 0) {
      return;
    }

    // For each place, get the icon, name and location.
    places.forEach(function(place) {
      if (!place.geometry) {
        console.log("Returned place contains no geometry");
        return;
      }
      setAddress(place);
      addMarker(place.geometry.location);
    });
  });

  function addMarker(latLang) {
    // Clear out the old markers.
    markers.forEach(function(marker) {
      marker.setMap(null);
    });
    
    markers = [];

    var bounds = new google.maps.LatLngBounds();
    bounds.extend(latLang);

    // Create a marker for each place.
    markers.push(new google.maps.Marker({
      map: map,
      icon: icon,
      position: latLang,
    }));

    map.fitBounds(bounds);
  }

  function setAddress(place) {
    address.value = parsePlace(place, 'address');
    city.value = parsePlace(place, 'city');
    suburb.value = parsePlace(place, 'suburb');
    latitude.value = parsePlace(place, 'latitude');
    longitude.value = parsePlace(place, 'longitude');
  }

  function parsePlace(place, type) {
    var result = '';
    switch(type) {
      case 'address':
        result = place.formatted_address;
        break;
      case 'city':
        result = extractAddressComponents(place.address_components, 'locality');
        break;
      case 'suburb':
        result = extractAddressComponents(place.address_components, 'sublocality');
        break;
      case 'latitude':
        result = place.geometry.location.lat()
        break;
      case 'longitude':
        result = place.geometry.location.lng()
        break;
    }

    return result;
  }

  function extractAddressComponents(address_components, text_data) {
    var result = address_components.find(function(element) { return element.types.includes(text_data)})

    if(result !== undefined) {
      return result.long_name
    } else {
      return ''
    }
  }
}