//
//  DJIAircraftAnnotation.swift
//  WayPointsDemo
//
//  Created by Krisha Jivani on 7/17/22.
//

import Foundation
import MapKit

class DJIAircraftAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    weak var annotationView: DJIAircraftAnnotationView?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
    }
    
    func updateHeading(_ heading: Float) {
        if (annotationView != nil) {
            annotationView?.updateHeading(heading)
        }
    }
    
}
