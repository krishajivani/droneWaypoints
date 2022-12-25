//
//  DJIRootViewController.swift
//  WayPointsDemo
//
//  Created by Krisha Jivani on 7/15/22.
//

import Foundation
import UIKit
import DJISDK
import MapKit
import CoreLocation

class DJIRootViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, DJIFlightControllerDelegate, DJISDKManagerDelegate {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet weak var editBtn: UIButton!
    private var isEditingPoints = false //says if edit mode is on or off
    
    private var mapController: DJIMapController?
    private var tapGesture: UITapGestureRecognizer?
    
    //used to set map screen to current location
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocationCoordinate2D?
    
    //status view bar at top
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var hsLabel: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    private var droneLocation: CLLocationCoordinate2D?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startUpdateLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        registerApp()
        initUI()
        initData()
        
    }
    
    func initUI() {
        modeLabel.text = "MODE: N/A"
        gpsLabel.text = "GPS: 0"
        vsLabel.text = "VS: 0.0 M/S"
        hsLabel.text = "HS: 0.0 M/S"
        altitudeLabel.text = "Alt: 0 M"
    }
    
    func initData() {
        userLocation = kCLLocationCoordinate2DInvalid
        droneLocation = kCLLocationCoordinate2DInvalid
        mapController = DJIMapController()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(addWayPoints(_:)))
        mapView.addGestureRecognizer(tapGesture!)
    }
    
    func registerApp() {
        //DJISDKManager.registerApp(with: self)
        gpsLabel.text = "registerApp"
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //add pin annotation upon finger tap on map
    @objc func addWayPoints(_ tapGesture: UITapGestureRecognizer?) {
        let point = tapGesture!.location(in: mapView)
        
        if tapGesture?.state == .ended {
            if isEditingPoints {
                mapController?.add(point, with: mapView)
            }
        }
    }
    
    //button toggles between "edit mode", where pins can be added, and "reset", which removes all pins and sets state to "non-edit mode"
    @IBAction private func editBtnAction(_ sender: Any) {
        
        if isEditingPoints {
            mapController?.cleanAllPoints(with: mapView)
            editBtn.setTitle("Edit", for: .normal)
        }
        else {
            editBtn.setTitle("Reset", for: .normal)
        }
        
        isEditingPoints = !isEditingPoints
    }
    
    @IBAction private func focusMapAction(_ sender: Any) {
        
        if CLLocationCoordinate2DIsValid(droneLocation!) {
            let region = MKCoordinateRegion(center: droneLocation!, latitudinalMeters: 500, longitudinalMeters: 500)

            mapView.setRegion(region, animated: true)

        }
        
//        if CLLocationCoordinate2DIsValid(userLocation!) {
//            let region = MKCoordinateRegion(center: userLocation!, latitudinalMeters: 500, longitudinalMeters: 500)
//
//            mapView.setRegion(region, animated: true)
//
//        }
        
        //modeLabel.text = "HEHEHE"
        
        
    }
    
    
    //MKMapViewDelegate Method
    // returns the view associated with the specified annotation object
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKPointAnnotation {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin_Annotation")
            pinView.pinTintColor = .purple
            return pinView
        }
        else if annotation is DJIAircraftAnnotation {
            let annoView = DJIAircraftAnnotationView(annotation: annotation, reuseIdentifier: "Aircraft_Annotation")
            (annotation as? DJIAircraftAnnotation)?.annotationView = annoView
            return annoView
        }

        return nil
    }
    
    //CLLocation Method
    func startUpdateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            if locationManager == nil {
                locationManager = CLLocationManager()
                locationManager?.delegate = self
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                locationManager?.distanceFilter = CLLocationDistance(0.1)
                
                if ((locationManager?.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) != nil) {
                    locationManager?.requestAlwaysAuthorization()
                }
                locationManager?.startUpdatingLocation()
            }
        }
        else {
//            let alert = UIAlertView(title: "Location Service is not available", message: "", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "")
//            alert.show()
            print("Oops, location service not available")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if let coordinate = location?.coordinate {
            userLocation = coordinate
        }
    }
    
    //DJISDKManagerDelegate Methods
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            hsLabel.text = "registererror"
            let registerResult = "Registration Error:\(error.localizedDescription)"
            showMessage("Registration Result", registerResult, nil, "OK")
        }
        else {
            var isConn = DJISDKManager.startConnectionToProduct()
            hsLabel.text = "not" + String(isConn)
        }
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        NSLog("SDK downloading db file \(progress.completedUnitCount / progress.totalUnitCount)")

    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        modeLabel.text = "entered"
        if product != nil {
            let flightController = DemoUtility.fetchFlightController()
            if let flightController = flightController {
                flightController.delegate = self
            }
            //print("product connected")
            modeLabel.text = "connected"
        }
        else {
            showMessage("Product disconnected", nil, nil, "OK")
            modeLabel.text = "disconnected"
        }

    }
    

    
    //DJIFlightControllerDelegate
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        // update drone location with aircraft's current location
        droneLocation = state.aircraftLocation?.coordinate
        vsLabel.text = "flightentered"

        modeLabel.text = "Mode: " + state.flightModeString
        gpsLabel.text = "GPS: " + String(UInt(state.satelliteCount))
        //vsLabel.text = "VS: " + String(state.velocityZ)  + " M/S"
        hsLabel.text = "HS: " + String(sqrtf(state.velocityX * state.velocityX + state.velocityY * state.velocityY)) + " M/S"
        altitudeLabel.text = "Alt: " + String(state.altitude) + " M"
        
        mapController?.updateAircraftLocation(droneLocation!, with: mapView)
        let radianYaw = RADIAN(state.attitude.yaw)
        mapController?.updateAircraftHeading(Float(radianYaw))
    }

}
