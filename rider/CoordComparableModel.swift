//
//  CoordComparableModel.swift
//  rider
//
//  Created by admin on 1/4/17.
//  Copyright © 2017 BicycleBNB. All rights reserved.
//

import Foundation
import CoreLocation

class CoordComparableModel {
    
    var coordinate: CLLocation?
    var proximityInMeter: Double {
        get {
            if let myLocation = AppDelegate.appDelegate.lastLocation,
                let targetLocation = self.coordinate {
                return myLocation.distance(from: targetLocation)
            } else {
                return Double.greatestFiniteMagnitude
            }
        }
    }
    
    
    func proximity() -> String? {
        if proximityInMeter < Double.greatestFiniteMagnitude {
            let proximityInMI = proximityInMeter * 0.621371 / 1000
            return String(format: "%.2f mi", proximityInMI)
        } else {
            return "N/A"
        }
    }
    
    func coordTitle() -> String? {
        return ""
    }
    
    func coordSnippet() -> String? {
        return ""
    }
}


extension CoordComparableModel: Comparable {}

// MARK: Comparable

func <(lhs: CoordComparableModel, rhs: CoordComparableModel) -> Bool {
    if let myLocation = AppDelegate.appDelegate.lastLocation {
        if let coord1 = lhs.coordinate {
            if let coord2 = rhs.coordinate {
                return myLocation.distance(from: coord1) < myLocation.distance(from: coord2)
            }
            return true
        }
    }
    return false
}
// MARK: Equatable

func ==(lhs: CoordComparableModel, rhs: CoordComparableModel) -> Bool {
    if let myLocation = AppDelegate.appDelegate.lastLocation,
        let coord1 = lhs.coordinate,
        let coord2 = rhs.coordinate {
        return myLocation.distance(from: coord1) == myLocation.distance(from: coord2)
    }
    return false
}



protocol CoordComparableModelDelegate: class {
    func coordComparableModel(_ selectedModel: CoordComparableModel?, didTappedOn viewController: MapViewController)
}
