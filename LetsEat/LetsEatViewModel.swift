//
//  LetsEatViewModel.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import Foundation
import CoreLocation
import Dispatch

class ViewModel: ObservableObject {
    @Published var model: LetsEatModel = LetsEatModel()
    
    @Published var isLoading: Bool = true
    
    func getIsLoading() -> Bool {
        return isLoading
    }
    
    func startLoadingScreen() { // Very hacky bad way to do this most likely
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("changing")
            self.isLoading = false
        }
    }
    
    // MARK - Intent: Update restaurant being suggested
    func updateSuggestion() {
        model.updateSuggestion()
    }
    
    // MARK - Model Information for View
    func getSuggestionName() -> String {
        model.currentSuggestion.name
    }

    func getAddress() -> String {
        model.currentSuggestion.address
    }
    
    // MARK - Get Location Info (Might not be the right place for this)
    func getLat() -> Float {
        Float(model.getLatitude())
    }
    
    func getLong() -> Float {
        Float(model.getLongitude())
    }
    
    // MARK - HTTP Requests
    let baseUrlString = "https://let-s-eat-api-gateway-d3f77p7e.ue.gateway.dev"
    
    // MARK - HTTP Request Functions
    func getReccomendations(lat: Float, long: Float) {
        print("Getting restaurant reccomendations.")
        
        let semaphore = DispatchSemaphore.init(value: 0) // cannot edit model from separate thread so need to wait until request completes before appending to the suggestion queue in model. Probably a better solution, but using this for now. 
        
        let url = URL(string: baseUrlString + "/restaurant")
        guard let requestUrl = url else {
            print("Request failed, url inaccessible.")
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["lat" : model.getLatitude(), "long" : model.getLongitude()]
        print("Lat: \(model.getLatitude())")
        print("Long: \(model.getLongitude())")
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        var jsonResp: Data = Data()
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // semaphore init
            defer { semaphore.signal() }
            
            if let error = error {
                print("Error \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            if let data = data, let _ = String(data: data, encoding: .utf8) { // _ is dataString
                jsonResp = data
                //print("Response: \(dataString)")
            }
        }
        task.resume()
        
        semaphore.wait()
        
        // Parse JSON and add to model
        let restaurants: [LetsEatModel.RestaurantData] = try! JSONDecoder().decode([LetsEatModel.RestaurantData].self, from: jsonResp)
        for i in restaurants {
            model.addRestaurantToQueue(addition: i)
        }
    }
}
