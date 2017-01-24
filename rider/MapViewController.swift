//
//  MapViewController.swift
//  rider
//
//  Created by admin on 1/9/17.
//  Copyright © 2017 BicycleBNB. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    var mapFor : Int = 0 //0 : GroupRides, 1 : BikeShops
    var pinDelegate: CoordComparableModelDelegate?
    var markers: [GMSMarker] = []
    
    @IBOutlet var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        
        if mapFor == 0 {
            initPins(locations: AppDelegate.appDelegate.groupRides)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_GROUP_RIDES_UPDATED), object: nil, queue: nil) { notification in
                self.initPins(locations: AppDelegate.appDelegate.groupRides)
            }
        } else if mapFor == 1 {
            initPins(locations: AppDelegate.appDelegate.bikeShops)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_BIKE_SHOPS_UPDATED), object: nil, queue: nil) { notification in
                self.initPins(locations: AppDelegate.appDelegate.bikeShops)
            }
        } else if mapFor == 2 {
            initPins(locations: AppDelegate.appDelegate.accommodations)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_ACCOMMODATIONS_UPDATED), object: nil, queue: nil) { notification in
                self.initPins(locations: AppDelegate.appDelegate.accommodations)
            }
        } else if mapFor == 3 {
            initPins(locations: AppDelegate.appDelegate.races)
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_RACES_UPDATED), object: nil, queue: nil) { notification in
                self.initPins(locations: AppDelegate.appDelegate.races)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func initMapView() {
        if let lastLocation = AppDelegate.appDelegate.lastLocation {            
            let camera = GMSCameraPosition.camera(withTarget: lastLocation.coordinate, zoom: 12)
            mapView.isMyLocationEnabled = true
            mapView.delegate = self
            mapView.camera = camera
            
            NotificationCenter.default.removeObserver(self)
        } else {
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_LOCATION_UPDATED), object: nil, queue: nil) { notification in
                self.initMapView()
            }
        }
    }
    
    func initPins(locations coordModels: [CoordComparableModel]?) {
        guard (coordModels != nil) else {
            return
        }
        
        mapView?.clear()
        markers.removeAll()
        
        let path = GMSMutablePath()
        
        if let myLocation = AppDelegate.appDelegate.lastLocation {
            path.add(myLocation.coordinate)
        }
        
        var i : Int = 0
        for location in coordModels! {
            if let coord = location.coordinate?.coordinate {
                let marker = GMSMarker(position: coord)
                marker.title = location.coordTitle()
                marker.snippet = location.coordSnippet()
                marker.map = mapView
                marker.userData = location
                
                markers.append(marker)
                
                if i < 5 {
                    path.add(marker.position)
                }
                
                if i == 0 {
                    mapView?.selectedMarker = marker
                }
            }
            
            i = i + 1
        }
        
        let bounds = GMSCoordinateBounds(path: path)
        mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
    }
    @IBAction func onMyLocation(_ sender: Any) {
        if let lastLocation = AppDelegate.appDelegate.lastLocation {
            let updatedCamera = GMSCameraUpdate.setTarget(lastLocation.coordinate, zoom: 12)
            mapView?.animate(with: updatedCamera)
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
//    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
//        if let location = marker.userData as? CoordComparableModel {
//            pinDelegate?.coordComparableModel(location, didTappedOn: self)            
//        }
//    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let location = marker.userData as? CoordComparableModel {
            pinDelegate?.coordComparableModel(location, didTappedOn: self)
            //mapView.selectedMarker = marker
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        pinDelegate?.coordComparableModel(nil, didTappedOn: self)
    }
}

extension MapViewController {
    func onScroll(to coordModel: CoordComparableModel) {
        for marker in markers {
            if marker.userData as? CoordComparableModel == coordModel {
                mapView?.selectedMarker = marker
                
                //Move camera
                let updatedCamera = GMSCameraUpdate.setTarget(marker.position, zoom: 12)
                mapView?.animate(with: updatedCamera)
            }
        }
    }
    
    func onCameraTo(place: GMSPlace) {
        let updatedCamera = GMSCameraUpdate.setTarget(place.coordinate, zoom: 12)
        mapView?.animate(with: updatedCamera)
    }
}
