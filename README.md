# WMATA Metro Transparent Data Sets API XQuery Library

An XQuery library module for interacting with the [WMATA Metro Transparent Data Sets API](http://developer.wmata.com/docs), 
which offers methods describing Metrorail and Metrobus transit systems.  The methods for Metrorail include the order 
and location of rail stations by line, train arrival predictions for each station, service alerts, and 
elevator/escalator status.  The methods for Metrobus include bus schedules, bus stop details, and bus route shapes.

## Requirements, Dependencies, and Compatibility

A WMATA API key is required.  More info is available at the [WMATA Developer site](http://developer.wmata.com/).

This library is packaged in the [EXPath Package format](http://www.expath.org/spec/pkg) for convenient installation in 
XQuery implementation that support it.

To build this into an EXPath Package, you will need [Apache Ant](http://ant.apache.org/).  To install the package, you 
need an implementation of XQuery that supports the EXPath Package system.

This package is dependent on the [EXPath HTTP Client]() for making HTTP requests.

This package has been tested with eXist 2.0RC2.  

## Installation for eXist-db

To install in eXist-db, clone this repository and run ant, which will construct an EXPath Archive (.xar) file in 
the project's build folder. Then install the package via the eXist-db Package Manager, or place it in eXist-db's 
'autodeploy' folder.

## Usage

### Import the module

    import module namespace wmata="http://www.wmata.com";

### Supply your API key to any of the functions, e.g.:

    let $api-key := 'INSERT YOUR WMATA API KEY HERE'
    return
        wmata:get-rail-lines($api-key)