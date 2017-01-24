//
//  RaceModel.swift
//  rider
//
//  Created by admin on 1/19/17.
//  Copyright © 2017 BicycleBNB. All rights reserved.
//

import Foundation
import Kanna
import CoreLocation

class RaceModel: CoordComparableModel {
    var name: String?
    
    var startDate: String?
    var endDate: String?
    var url: String?
    var eventUrl: String?
    var location: String?
    var format: String?
    var type: String?
    var notes: String?
    
    override func coordTitle() -> String? {
        return name
    }
    
    override func coordSnippet() -> String? {
        return startDate
    }
}

extension RaceModel {
    static func extractLatLang(fromHTML html: String) -> [Int : (Double, Double)] {
        var result: [Int : (Double, Double)] = [:]
        
        do {
            let regex = try NSRegularExpression(pattern: "position = new google.maps.LatLng\\(([0-9.-]*),([0-9.-]*)\\);[\n\t\r ]*var marker_([0-9]{1,})")
            let nsSearchedString = html as NSString
            let searchedRange = NSMakeRange(0, html.characters.count)
            let matches = regex.matches(in:html, options:[], range:searchedRange)
            for match in matches {
                //                let matchText = nsSearchedString.substring(with:match.range);
                //                print("match: \(matchText)");
                
                let group1 : NSRange = match.rangeAt(1)
                let matchText1 = nsSearchedString.substring(with: group1)
                //                print("matchText1: \(matchText1)")
                
                let group2 = match.rangeAt(2)
                let matchText2 = nsSearchedString.substring(with: group2)
                //                print("matchText2: \(matchText2)")
                
                let group3 = match.rangeAt(3)
                let matchText3 = nsSearchedString.substring(with: group3)
                //                print("matchText3: \(matchText3)")
                
                if let index = Int(matchText3), let lat = Double(matchText1), let long = Double(matchText2) {
                    result[index] = (lat, long)
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        return result
    }
    
    static func parse(fromHTML html: String) -> [RaceModel] {
        let latLangs = extractLatLang(fromHTML: html)
        
        var result: [RaceModel] = []
        if let doc = HTML(html: html, encoding: .utf8) {
            if let snTable = doc.at_css("table[id='shortcode_list']") {
                for (index, tr) in snTable.css("tr").enumerated() {
                    //index == 0 -> TH
                    if index > 0 {
                        var model: RaceModel
                        model = RaceModel.init()
                        model.name = tr.at_css("td:nth-child(1)")?.text?.replacingOccurrences(of: "Add Review", with: "")
                        model.eventUrl = tr.at_css("td:nth-child(1)>a")?["href"]
                        model.location = tr.at_css("td:nth-child(2)")?.text
                        model.url = tr.at_css("td:nth-child(3)>a")?["href"]
                        //model.url = model.eventUrl?.replacingOccurrences(of: "#add_review", with: "")
                        model.startDate = tr.at_css("td:nth-child(4)")?.text
                        model.endDate = tr.at_css("td:nth-child(5)")?.text
                        model.type = tr.at_css("td:nth-child(7)")?.text
                        model.format = tr.at_css("td:nth-child(8)")?.text
                        model.notes = tr.at_css("td:nth-child(9)")?.text
                        
                        print("\(index): \(model.name) \(model.location)")
                        if let (lat, long) = latLangs[index - 1] {
                            model.coordinate = CLLocation(latitude: lat, longitude: long)
                            print("=>\(index): \(model.coordinate)")
                        }
                                                
                        result.append(model)
                    }
                }
            }
        }
        return result
    }
}

