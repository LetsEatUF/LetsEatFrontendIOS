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
        if locationManager.authorizationStatus != CLAuthorizationStatus.authorizedWhenInUse {
            
            // Need to get the location perms
            locationManager.requestWhenInUseAuthorization()
        }
    }

    var username: String = ""
    
    var groupName: String = ""
    
    var finalDecisionTitle: String = ""
    
    var locationManager: CLLocationManager =  CLLocationManager()
    
    func getLatitude() -> CLLocationDegrees {
        return locationManager.location?.coordinate.latitude ?? 0
    }
    
    func getLongitude() -> CLLocationDegrees {
        return locationManager.location?.coordinate.longitude ?? 0
    }
    
    var currentSuggestion: RestaurantData = RestaurantData()
    
    var suggestionQueue: Queue<RestaurantData> = Queue()
    
    mutating func updateSuggestion() {
        self.currentSuggestion = suggestionQueue.dequeue() ?? RestaurantData()
    }
    
    mutating func addRestaurantToQueue(addition: RestaurantData) {
        suggestionQueue.enqueue(addition)
    }
    
    struct RestaurantData: Decodable { 
        var name: String = "No suggestion available."
        var address: String = "No address available."
        var rating: Float32 = 0
        var ratings: Int32 = 0
        var price: Int32 = 0
        var photo: String = ""
    }
}
