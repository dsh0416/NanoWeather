require 'json'
require 'mongo'

Mongo::Logger.logger.level = ::Logger::FATAL

while true
  puts 'INPUT PARAMETER'
  input = gets.chomp

  if input == '-1'
    exit(0)
  end

  if input == '0'
    puts 'SENSITIVITY'
    input = gets.chomp.to_i
    db = Mongo::Client.new('mongodb://hacker:hacker@localhost:27017/admin')
    collection_vd = db['vd_info']
    collection_sensor = db['sensor_info']

    ans = Array.new

    collection_sensor.find.to_a.each do |sensor|
      occ_status = 0
      spd_status = 0
      occ_now = 0
      spd_now = 0
      collection_vd.find(SessionId:sensor[:SessionId]).sort(time:-1).limit(input).to_a.each_with_index do |vd, index|
        occ_now = vd[:AvgOcc].to_f if index == 0
        spd_now = vd[:AvgSpd].to_f if index == 0
        occ_status += vd[:AvgOcc].to_f
        spd_status += vd[:AvgSpd].to_f
      end
      occ_status /= input
      spd_status /= input
      ans << {Lat:sensor[:StartWgsY],Lng:sensor[:StartWgsX],weight:(occ_now - occ_status)} if (occ_status - occ_now < -3) and (spd_status - spd_now > 5)
    end
    html = File.open('./index.html','w+')
    html.write('<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
  <meta charset="utf-8">
  <title>Circles</title>
  <style>
      html, body {
          height: 100%;
          margin: 0;
          padding: 0;
      }
      #map {
          height: 100%;
      }
  </style>
</head>
<body>
<div id="map"></div>
<script>

    // This example creates circles on the map, representing populations in North
    // America.

    // First, create an object containing LatLng and population for each city.
    var citymap = {')

    ans.each do |location|
        html.write("#{rand(999999)}: {center: {lat: #{location[:Lat]}, lng:#{location[:Lng]}}, population: #{location[:weight]}},")
    end

    html.write('        vancouver: {
            center: {lat: 49.25, lng: -123.1},
            population: 0
        }
    };

    function initMap() {
        // Create the map.
        var map = new google.maps.Map(document.getElementById(\'map\'), {
            zoom: 12,
            center: {lat: 25.047073 , lng: 121.536185},
            mapTypeId: google.maps.MapTypeId.ROADMAP
        });

        // Construct the circle for each value in citymap.
        // Note: We scale the area of the circle based on the population.
        for (var city in citymap) {
            // Add the circle for this city to the map.
            var cityCircle = new google.maps.Circle({
                strokeColor: \'#FF0000\',
    strokeOpacity: 0.8,
        strokeWeight: 2,
        fillColor: \'#FF0000\',
        fillOpacity: 0.35,
        map: map,
        center: citymap[city].center,
        radius: Math.sqrt(citymap[city].population) * 100
    });
    }
    }

    </script>
<script async defer
        src="https://maps.googleapis.com/maps/api/js?signed_in=true&callback=initMap"></script>
</body>
</html>')

    html.close

  end
end