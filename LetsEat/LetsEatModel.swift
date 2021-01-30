//
//  LetsEatModel.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import Foundation
import MapKit
import CoreLocation

struct LetsEatModel {
    init() {
        print("Model initializing...")
        if locationManager.authorizationStatus != CLAuthorizationStatus.authorizedWhenInUse {
            
            // Need to get the location perms
            print("Requesting location authorization.")
            locationManager.requestWhenInUseAuthorization()
        }
        print("Model initialized.")
    }
    
    var locationManager: CLLocationManager =  CLLocationManager()
    
    func getLatitude() -> CLLocationDegrees {
        return locationManager.location?.coordinate.latitude ?? 0
    }
    
    func getLongitude() -> CLLocationDegrees {
        return locationManager.location?.coordinate.longitude ?? 0
    }
    
    var suggestionQueue: [RestaurantData] = []
    
    mutating func addRestaurantToQueue(addition: RestaurantData) {
        suggestionQueue.append(addition)
    }
    
    struct RestaurantData: Decodable {
        let name: String
        let address: String
        let rating: Float32
        let ratings: Int32
        let price: Int32
        let photo: String
    }
}
