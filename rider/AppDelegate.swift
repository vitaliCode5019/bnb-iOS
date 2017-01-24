//
//  AppDelegate.swift
//  rider
//
//  Created by admin on 12/30/16.
//  Copyright © 2016 BicycleBNB. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locationManager: CLLocationManager?
    var window: UIWindow?

    private var _lastLocation: CLLocation?
    var lastLocation: CLLocation? {
        get {
            return _lastLocation
        }
        set {
            _lastLocation = newValue
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_LOCATION_UPDATED), object: nil, userInfo: nil)
            
            _groupRides?.sort()
            _bikeShops?.sort()
            _accommodations?.sort()
            _races?.sort()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_GROUP_RIDES_UPDATED), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_BIKE_SHOPS_UPDATED), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_ACCOMMODATIONS_UPDATED), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_RACES_UPDATED), object: nil, userInfo: nil)
        }
    }
    
    private var _groupRides: [GroupRideModel]?
    var groupRides: [GroupRideModel]? {
        get {
            return _groupRides
        }
        set {
            _groupRides = newValue
            _groupRides?.sort()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_GROUP_RIDES_UPDATED), object: nil, userInfo: nil)
        }
    }
    
    private var _bikeShops: [BikeShopModel]?
    var bikeShops: [BikeShopModel]? {
        get {
            return _bikeShops
        }
        set {
            _bikeShops = newValue
            _bikeShops?.sort()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_BIKE_SHOPS_UPDATED), object: nil, userInfo: nil)
        }
    }
    
    private var _accommodations: [AccommodationModel]?
    var accommodations: [AccommodationModel]? {
        get {
            return _accommodations
        }
        set {
            _accommodations = newValue
            _accommodations?.sort()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_ACCOMMODATIONS_UPDATED), object: nil, userInfo: nil)
        }
    }
    
    private var _races: [RaceModel]?
    var races: [RaceModel]? {
        get {
            return _races
        }
        set {
            _races = newValue
            _races?.sort()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: GlobalConstants.NOTIFY_RACES_UPDATED), object: nil, userInfo: nil)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.        
        GMSServices.provideAPIKey("AIzaSyAHmKdyoNWAA2krnMMgQfiYL-dmSVfnYpc")
        GMSPlacesClient.provideAPIKey("AIzaSyAHmKdyoNWAA2krnMMgQfiYL-dmSVfnYpc")
        
        locationManager = CLLocationManager.init()
        locationManager?.delegate = self
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}



extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {        
        if let lastLocation = AppDelegate.appDelegate.lastLocation,
            let toLocation = locations.last {
            guard lastLocation.distance(from: toLocation) > 100 else {
                return
            }
        }
        self.lastLocation = locations.last
    }
}
