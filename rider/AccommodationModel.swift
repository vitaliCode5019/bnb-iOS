//
//  AccommodationModel.swift
//  rider
//
//  Created by admin on 12/31/16.
//  Copyright © 2016 BicycleBNB. All rights reserved.
//

import Foundation
import CoreLocation

class AccommodationModel: CoordComparableModel {
    var imageUrl: String?
    var name: String?
    var price: String?
    var location: String?
    var category: String?
    var url: String?
    
    static func dummyData() -> AccommodationModel {
        let data: AccommodationModel
        data = AccommodationModel.init()
        
        
        data.imageUrl = "http://bicyclebnb.com/wp-content/uploads/2016/08/ice_screenshot_20161010-131252-400x314.png"
        data.name = "Triathlon Hermit House (Test)"
        data.price = "$ 30 (Test)"
        data.location = "Carlsbad Village, Carlsbad (Test)"
        data.category = "Apartment / Shared room (Test)"
        data.url = "http://bicyclebnb.com/properties/sf-condo/"
        
        return data
    }
    
    override func coordTitle() -> String? {
        return name
    }
    
    override func coordSnippet() -> String? {
        return price
    }
}

/*
 /* <![CDATA[ */
 var googlecode_property_vars = {"general_latitude":"40.781711","general_longitude":"-73.955927","path":"http:\/\/bicyclebnb.com\/wp-content\/themes\/wprentals\/\/css\/css-images","markers":"[[\"SF%20Condo\",\"37.7975788\",\"-122.43325140000002\",1,\"http%3A%2F%2Fbicyclebnb.com%2Fwp-content%2Fuploads%2F2016%2F10%2F20160704_104957.jpg\",\"%24%2075%20\",\"condos\",\"entire-home\",\"condosentire-home\",\"http%3A%2F%2Fbicyclebnb.com%2Fproperties%2Fsf-condo%2F\",3775,\"san-francisco\",\"\",75,\"0\",\"4\",\"0\",\"Condos\",\"Entire%20Home\"],[\"Triathlon%20Hermit%20House\",\"33.157708\",\"-117.33601199999998\",2,\"http%3A%2F%2Fbicyclebnb.com%2Fwp-content%2Fuploads%2F2016%2F08%2Fice_screenshot_20161010-131252.png\",\"%24%2030%20\",\"apartment\",\"shared-room\",\"apartmentshared-room\",\"http%3A%2F%2Fbicyclebnb.com%2Fproperties%2Ftriathlon-hermit-house%2F\",3561,\"carlsbad\",\"carlsbad-village\",30,\"\",\"1\",\"\",\"Apartment\",\"Shared%20Room\"]]","single_marker":"[[\"SF%20Condo\",37.7975788,-122.4332514,1,\"http%3A%2F%2Fbicyclebnb.com%2Fwp-content%2Fuploads%2F2016%2F10%2F20160704_104957.jpg\",\"%24%2075%20\",\"condos\",\"entire-home\",\"condosentire-home\",\"http%3A%2F%2Fbicyclebnb.com%2Fproperties%2Fsf-condo%2F\",3775,\"san-francisco\",\"\",75,\"0\",\"4\",\"0\",\"Condos\",\"Entire%20home\"]]","single_marker_id":"3775","camera_angle":"0","idx_status":"0","page_custom_zoom":"16","current_id":"3775","generated_pins":"0","small_map":"1"};
 /* ]]> */
*/

extension AccommodationModel {
    static func parse(fromHTML html: String) -> [AccommodationModel] {
        var result: [AccommodationModel] = []
        
        do {
            let regex = try NSRegularExpression(pattern: "var googlecode_property_vars = (\\{.*\\})")
            let nsSearchedString = html as NSString
            let searchedRange = NSMakeRange(0, html.characters.count)
            let matches = regex.matches(in:html, options:[], range:searchedRange)
            
            for match in matches {
//                let matchText = nsSearchedString.substring(with:match.range);
//                print("match: \(matchText)");
                
                let group1 : NSRange = match.rangeAt(1)
                let matchText1 = nsSearchedString.substring(with: group1)
                //print("matchText1: \(matchText1)")
                
                if let jsonString = matchText1.removingPercentEncoding {
                    var json = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: []) as! [String:Any]
                    if let markers = json["markers"] as? String {
                        let json1 = try JSONSerialization.jsonObject(with: markers.data(using: .utf8)!, options: []) as! [[Any]]
                        for marker in json1 {
                            var model: AccommodationModel
                            model = AccommodationModel.init()
                            model.name = marker[0] as? String
                            if let lat = Double((marker[1] as? String)!), let long = Double((marker[2] as? String)!) {
                                model.coordinate = CLLocation(latitude: lat, longitude: long)
                            }
                            model.imageUrl = marker[4] as? String
                            model.price = marker[5] as? String
                            model.url = marker[9] as? String
                            
                            model.category = (marker[17] as? String)?.uppercased()
                            if let category1 = model.category, let category2 = marker[18] as? String {
                                if !category2.isEmpty {
                                    model.category = category1 + "/" + category2.uppercased()
                                }
                            }
                            
                            model.location = (marker[11] as? String)?.uppercased().replacingOccurrences(of: "-", with: " ")
                            if let location1 = model.location, let location2 = marker[12] as? String {
                                if !location2.isEmpty {
                                    model.location = location1 + "/" + location2.uppercased().replacingOccurrences(of: "-", with: " ")
                                }
                            }
                            
                            result.append(model)
                        }
                    }
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        
        return result
    }
}
