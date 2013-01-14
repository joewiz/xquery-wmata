xquery version "3.0";

(:
 : Copyright (c) 2012-2013
 :     Joe Wicentowski. All rights reserved.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:~  
 : An XQuery module for interacting with the WMATA Metro Transparent Data Sets API, which offers 
 : methods describing Metrorail and Metrobus transit systems.  The methods for Metrorail include 
 : the order and location of rail stations by line, train arrival predictions for each station, 
 : service alerts, and elevator/escalator status.  The methods for Metrobus include bus schedules, 
 : bus stop details, and bus route shapes.
 :
 : @see http://developer.wmata.com/docs
 :
 : @author Joe Wicentowski
 :)

module namespace wmata = "http://www.wmata.com";

import module namespace http = "http://expath.org/ns/http-client";

(:~
 : Method 1, Rail Lines:
 : Returns descriptive information about all rail lines.
 : @see http://developer.wmata.com/docs/read/Method1
 : @param $api-key your API key
 : @return descriptive information about all rail lines
 :)
declare function wmata:get-rail-lines($api-key as xs:string) as element(wmata:LinesResp) {
    let $api-url := 'http://api.wmata.com/Rail.svc/Lines'
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 2, Rail Stations:
 : Returns list of all stations in the system.
 : @see http://developer.wmata.com/docs/read/Method2 
 : @param $api-key your API key
 : @return list of all stations in the system
 :)
declare function wmata:get-rail-stations($api-key as xs:string) as element(wmata:StationsResp) {
    let $api-url := 'http://api.wmata.com/Rail.svc/Stations'
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 2, Rail Stations:
 : Returns list of all stations by line.
 : @see http://developer.wmata.com/docs/read/Method2 
 : @param $api-key your API key
 : @param $rail-line-id the ID of a line
 : @return list of all stations by line
 :)
declare function wmata:get-rail-stations($api-key as xs:string, $rail-line-id as xs:string) as element(wmata:StationsResp) {
    let $api-url := 'http://api.wmata.com/Rail.svc/Stations'
    let $param := concat('LineCode=', $rail-line-id)
    return
        wmata:_request($api-url, $param, $api-key)
};

(:~
 : Method 3, Rail Station Info:
 : Returns descriptive information about a single station.
 : @see http://developer.wmata.com/docs/read/Method_3_Station_Info
 : @param $api-key your API key
 : @param $station-id the ID of a station
 : @return descriptive information about a single station
 :)
 declare function wmata:get-rail-station-info($api-key as xs:string, $station-id as xs:string) as element(wmata:Station){
    let $api-url := 'http://api.wmata.com/Rail.svc/StationInfo'
    let $param := concat('StationCode=', $station-id)
    return
        wmata:_request($api-url, $param, $api-key)
};

(:~
 : Method 4, Rail Paths:
 : Returns a list of stations between two given stations.
 : @see http://developer.wmata.com/docs/read/Method_4_Path
 : @param $api-key your API key
 : @param $from-station-id the ID of the departure station
 : @param $to-station-id the ID of the destination station
 : @return a list of stations between two given stations
 :)
declare function wmata:get-rail-paths($api-key as xs:string, $from-station-id as xs:string, $to-station-id as xs:string) as element(wmata:PathResp){
    let $api-url := 'http://api.wmata.com/Rail.svc/Path'
    let $params := 
        (
        concat('FromStationCode=', $from-station-id)
        ,
        concat('ToStationCode=', $to-station-id)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 5, Rail Station Prediction:
 : Returns train arrival information for all trains in the system.
 : @see http://developer.wmata.com/docs/read/Method_5
 : @param $api-key your API key
 : @return train arrival information as it appears on the Public Information Displays throughout the system
 :)
declare function wmata:get-rail-station-prediction($api-key as xs:string) as element(wmata:AIMPredictionResp){
    let $api-url := concat('http://api.wmata.com/StationPrediction.svc/GetPrediction/', 'All')
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 5, Rail Station Prediction:
 : Returns train arrival information for one or more stations the system.
 : @see http://developer.wmata.com/docs/read/Method_5
 : @param $api-key your API key
 : @param $station-ids the IDs of one or more stations
 : @return train arrival information as it appears on the Public Information Displays throughout the system
 :)
declare function wmata:get-rail-station-prediction($api-key as xs:string, $station-ids as xs:string+) as element(wmata:AIMPredictionResp){
    let $params := string-join($station-ids, ',')
    let $api-url := concat('http://api.wmata.com/StationPrediction.svc/GetPrediction/', $params)
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 6, Rail Incidents:
 : Returns rail incidents as they appear on the the Public Information Displays throughout the transit system.
 : @see http://developer.wmata.com/docs/read/Method_6_Rail_Incidents
 : @param $api-key your API key
 : @return rail incidents as they appear on the the Public Information Displays throughout the transit system
 :)
declare function wmata:get-rail-incidents($api-key as xs:string) as element(wmata:IncidentsResp) {
    let $api-url := 'http://api.wmata.com/Incidents.svc/Incidents'
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 7, Elevator / Elevator Incidents:
 : Returns elevator and escalator statuses as they appear on the Public Information Displays throughout the transit system.
 : @see http://developer.wmata.com/docs/read/Method_7_Elevator_Incidents
 : @param $api-key your API key
 : @return elevator and escalator statuses as they appear on the Public Information Displays throughout the transit system
 :)
declare function wmata:get-elevator-incidents($api-key as xs:string, $station-id as xs:string) as element(wmata:ElevatorIncidentsResp) {
    let $api-url := 'http://api.wmata.com/Incidents.svc/ElevatorIncidents'
    let $param := concat('StationCode=', $station-id)
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 8, Station Entrances:
 : Returns entrances (including elevators) to Metro stations. All entrances will be returned.
 : @see http://developer.wmata.com/docs/read/Method8
 : @param $api-key your API key
 : @return entrances (including elevators) to Metro stations
 :)
declare function wmata:get-station-entrances($api-key as xs:string) as element(wmata:StationEntrancesResp) {
    let $api-url := 'http://api.wmata.com/Rail.svc/StationEntrances'
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 8, Station Entrances:
 : Returns entrances (including elevators) to Metro stations, ordered by distance from a geolocation within a certain radius..
 : @see http://developer.wmata.com/docs/read/Method8
 : @param $api-key your API key
 : @param $latitude latitude of point from which to measure radius
 : @param $longitude longitude of point from which to measure radius
 : @param $radius a radius expressed in meters
 : @return entrances (including elevators) to Metro stations
 :)
declare function wmata:get-station-entrances($api-key as xs:string, $latitude as xs:long, $longitude as xs:long, $radius as xs:integer) as element(wmata:StationEntrancesResp) {
    let $api-url := 'http://api.wmata.com/Rail.svc/StationEntrances'
    let $params :=
        (
        concat('lat=', $latitude),
        concat('lon=', $longitude),
        concat('rad=', $radius)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 9, Bus Routes:
 : Returns a list of all bus routes.
 : @see http://developer.wmata.com/docs/read/Method_9
 : @param $api-key your API key
 : @return a list of all bus routes
 :)
declare function wmata:get-bus-routes($api-key as xs:string) as element(wmata:RoutesResp) {
    let $api-url := 'http://api.wmata.com/Bus.svc/Routes'
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 10, Bus Stops:
 : Returns a list of all bus stops.  All stops will be returned.
 : @see http://developer.wmata.com/docs/read/Method_10
 : @param $api-key your API key
 : @return a list of all bus stops
 :)
declare function wmata:get-bus-stops($api-key as xs:string) as element(wmata:StopsResp) {
    let $api-url := 'http://api.wmata.com/Bus.svc/Stops'
    return
        wmata:_request($api-url, (), $api-key)
};

(:~
 : Method 10, Bus Stops:
 : Returns a list of bus stops, ordered by distance from a geolocation within a certain radius.
 : @see http://developer.wmata.com/docs/read/Method_10
 : @param $api-key your API key
 : @param $latitude latitude of point from which to measure radius
 : @param $longitude longitude of point from which to measure radius
 : @param $radius a radius expressed in meters
 : @return a list of bus stops
 :)
declare function wmata:get-bus-stops($api-key as xs:string, $latitude as xs:long, $longitude as xs:long, $radius as xs:integer) as element(wmata:StopsResp) {
    let $api-url := 'http://api.wmata.com/Bus.svc/Stops'
    let $params :=
        (
        concat('lat=', $latitude),
        concat('lon=', $longitude),
        concat('rad=', $radius)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 11, Bus Schedule by Route:
 : Returns the bus schedule associated with a requested route.
 : @see http://developer.wmata.com/docs/read/Method_11
 : @param $api-key your API key
 : @param $route-id the ID of a route
 : @param $date a date
 : @param $include-variations Some routes (like "10B") have variations like "10Bv1", "10Bv4". You can retrieve the schedule for all variations at once or individually.
 : @return the bus schedule associated with a requested route
 :)
declare function wmata:get-bus-stops($api-key as xs:string, $route-id as xs:string, $date as xs:date, $include-variations as xs:boolean) as element(wmata:RouteScheduleInfo) {
    let $api-url := 'http://api.wmata.com/Bus.svc/RouteSchedule'
    let $params := 
        (
        concat('routeId=', $route-id),
        concat('date=', $date),
        concat('includingVariations=', $include-variations)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 12, Bus Route Details:
 : Returns a sequence of lat/long points which can be used to describe a specific bus route.
 : @see http://developer.wmata.com/docs/read/Method_12
 : @param $api-key your API key
 : @param $route-id the ID of a route
 : @param $date a date
 : @return a sequence of lat/long points which can be used to describe a specific bus route
 :)
declare function wmata:get-bus-route-details($api-key as xs:string, $route-id as xs:string, $date as xs:date) as element(wmata:RouteDetailsInfo) {
    let $api-url := 'http://api.wmata.com/Bus.svc/RouteDetails'
    let $params := 
        (
        concat('routeId=', $route-id),
        concat('date=', $date)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 13, Bus Positions:
 : Returns the real-time positions of each bus traveling a specified route.  Bus position information is updated every two minutes or less.
 : @see http://developer.wmata.com/docs/read/Method_13
 : @param $api-key your API key
 : @param $route-id the ID of a route
 : @param $include-variations Some routes (like "10B") have variations like "10Bv1", "10Bv4". You can retrieve the schedule for all variations in one piece or separately.
 : @return the real-time positions of each bus traveling a specified route
 :)
declare function wmata:get-bus-positions($api-key as xs:string, $route-id as xs:string, $include-variations as xs:boolean) as element(wmata:BusPositionsResp) {
    let $api-url := 'http://api.wmata.com/Bus.svc/BusPositions'
    let $params := 
        (
        concat('routeId=', $route-id),
        concat('includingVariations=', $include-variations)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 13, Bus Positions:
 : Returns the real-time positions of each bus travel a specified route inside a specified area.  Bus position information is updated every two minutes or less.
 : @see http://developer.wmata.com/docs/read/Method_13
 : @param $api-key your API key
 : @param $route-id the ID of a route
 : @param $include-variations Some routes (like "10B") have variations like "10Bv1", "10Bv4". You can retrieve the schedule for all variations in one piece or separately.
 : @param $latitude latitude of point from which to measure radius
 : @param $longitude longitude of point from which to measure radius
 : @param $radius a radius expressed in meters
 : @return the real-time positions of each bus traveling a specified route inside a specified area
 :)
declare function wmata:get-bus-positions($api-key as xs:string, $route-id as xs:string, $include-variations as xs:boolean, $latitude as xs:long, $longitude as xs:long, $radius as xs:integer) as element(wmata:BusPositionsResp) {
    let $api-url := 'http://api.wmata.com/Bus.svc/BusPositions'
    let $params := 
        (
        concat('routeId=', $route-id),
        concat('includingVariations=', $include-variations),
        concat('lat=', $latitude),
        concat('lon=', $longitude),
        concat('rad=', $radius)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 14, Bus Schedule by Stop:
 : Returns the bus schedule for a specific bus stop.
 : @see http://developer.wmata.com/docs/read/Method_14
 : @param $api-key your API key
 : @param $stop-id a bus stop ID
 : @param $date a date
 : @return the bus schedule for a specific bus stop
 :)
declare function wmata:get-bus-schedule-by-stop($api-key as xs:string, $stop-id as xs:string, $date as xs:date) as element(wmata:StopScheduleInfo) {
    let $api-url := 'http://api.wmata.com/Bus.svc/StopSchedule'
    let $params := 
        (
        concat('stopId=', $stop-id),
        concat('date=', $date)
        )
    return
        wmata:_request($api-url, $params, $api-key)
};

(:~
 : Method 15, Bus Prediction:
 : Returns the bus arrival predictions for a specific bus stop according to the real-time positions of the buses.
 : @see http://developer.wmata.com/docs/read/Method_15_BusPrediction
 : @param $api-key your API key
 : @param $stop-id a bus stop ID
 : @return the bus arrival predictions for a specific bus stop according to the real-time positions of the buses
 :)
declare function wmata:get-bus-prediction($api-key as xs:string, $stop-id as xs:string) as element(wmata:NextBusResponse) {
    let $api-url := 'http://api.wmata.com/NextBusService.svc/Predictions'
    let $param := concat('StopID=', $stop-id)
    return
        wmata:_request($api-url, $param, $api-key)
};

(:~
 : Helper function that sends the requests to the WMATA API 
 : @param $api-url the URL of the API method
 : @param $params optional URL parameters, supplied in the form name=value
 : @param $api-key your API key
 :)
declare function wmata:_request($api-url as xs:string, $params as xs:string*, $api-key as xs:string) {
    let $params := ($params, concat('api_key=', $api-key))
    let $signed-url := concat($api-url, '?', string-join($params, '&amp;'))
    let $request-element := <http:request method="GET" href="{$signed-url}"/>
    let $request := http:send-request($request-element)
    let $request-body := $request[2]/*
    return
        $request-body
};