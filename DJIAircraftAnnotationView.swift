//
//  DJIAircraftAnnotationView.swift
//  WayPointsDemo
//
//  Created by Krisha Jivani on 7/17/22.
//

import Foundation
import MapKit

class DJIAircraftAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        isEnabled = false
        isDraggable = false
        image = UIImage(named: "aircraft")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateHeading(_ heading: Float) {
        transform = .identity
        transform = CGAffineTransform(rotationAngle: CGFloat(heading))
        
    }
}
