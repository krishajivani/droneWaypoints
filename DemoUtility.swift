//
//  DemoUtility.swift
//  WayPointsDemo
//
//  Created by Family Jivani on 7/18/22.
//

import Foundation
import DJISDK
import UIKit


//#define RADIAN(x) ((x)*M_PI/180.0)
func RADIAN(_ x: Double) -> Double {
    return x * Double.pi/180.0
}

func showMessage(_ title: String?, _ message: String?, _ target: Any?, _ cancleBtnTitle: String?) {
    DispatchQueue.main.async {
//        let alert = UIAlertView(title: title!, message: message!, delegate: target, cancelButtonTitle: cancleBtnTitle, otherButtonTitles: "")
//        alert.show()
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancleBtnTitle, style: .cancel, handler: nil))
    }
    
}

class DemoUtility {
    class func fetchFlightController() -> DJIFlightController? {
        if (DJISDKManager.product() == nil) {
            return nil
        }
        if DJISDKManager.product() is DJIAircraft {
            return (DJISDKManager.product() as? DJIAircraft)?.flightController
        }
        return nil
    }
}
