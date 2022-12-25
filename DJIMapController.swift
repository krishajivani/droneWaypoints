//
//  DJIMapController.swift
//  WayPointsDemo
//
//  Created by Family Jivani on 7/15/22.
//

import Foundation
import MapKit
import UIKit

//This class will be used to deal with MKAnnotations (in this case, waypoints)

class DJIMapController {
    //array that stores waypoint objects
    var editPoints: [CLLocation]
    var aircraftAnnotation: DJIAircraftAnnotation?
    
    init() {
        //super.init()
        self.editPoints = [CLLocation]()
        //self.aircraft = nil
    }
    
    // Adds waypoints in mapview
    func add(_ point: CGPoint, with mapView: MKMapView?) {
        //add point in waypoints array
        let coordinate = mapView?.convert(point, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
        editPoints.append(location)
        
        //add pin annotation on map
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView?.addAnnotation(annotation)
    }
    
    // Removes all waypoints in mapview
    func cleanAllPoints(with mapView: MKMapView?) {
        //removes all points in waypoint array
        editPoints.removeAll()
        
        //remove all pin annotations from map
        var pins: [MKAnnotation]? = nil
        if let annotations = mapView?.annotations {
            pins = annotations
        }
        for i in 0..<(pins?.count ?? 0) {
            let pin = pins?[i]
            if let pin = pin {
                if !(pin.isEqual(aircraftAnnotation)) {
                    mapView?.removeAnnotation(pin)
                }
            }
        }
    }
    
    // Returns the current waypoint objects on the map in an array
    // type: multiple CCLocation objects
    func wayPoints() -> [AnyHashable]? {
        return self.editPoints
    }
    
    // Update Aircraft's location in mapview
    func updateAircraftLocation(_ location: CLLocationCoordinate2D, with mapView: MKMapView) {
        if (aircraftAnnotation == nil) {
            aircraftAnnotation = DJIAircraftAnnotation(coordinate: location)
            mapView.addAnnotation(aircraftAnnotation!)
        }
        
        aircraftAnnotation?.setCoordinate(location)
    }
    
    // Update Aircraft's heading in mapview
    func updateAircraftHeading(_ heading: Float) {
        aircraftAnnotation?.updateHeading(heading)
    }
}
