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
    @Published var waitingForUsername: Bool = true // TODO: replace these bools with enums
    @Published var hasFoundMatch: Bool = false
    
    func getIsLoading() -> Bool {
        isLoading
    }
    
    func getIsWaitingForUsername() -> Bool {
        waitingForUsername
    }
    
    func getHasFoundMatch() -> Bool {
        hasFoundMatch
    }
    
    func startLoadingScreen() { // Very hacky bad way to do this most likely
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isLoading = false
        }
    }
    
    // MARK - Intent: Username submission
    
    func submitLogin(username: String) {
        model.username = username
        
        sendLogin(username: model.username)
        
        waitingForUsername = false
    }
    
    // MARK - Intent: Group submission
    func submitGroup(groupName: String) {
        model.groupName = groupName
        postGroupName()
        queryForGroup()
    }
    
    func getSuccessfulMatchTitle() -> String {
        model.finalDecisionTitle
    }
    
    // MARK - Intent: Update restaurant being suggested
    func updateSuggestion() {
        model.updateSuggestion()
    }
    
    // MARK - Intent: Yay Functionality
    func submitYay() {
        // Want to check if we have a group if we aren't already in one
        if model.groupName == "" {
            queryForGroup()
        }
        
        if model.groupName == "" {
            model.finalDecisionTitle = model.currentSuggestion.name
            self.hasFoundMatch = true
            return
        } else {
            // TODO: Query the database to see if we have a match. if match, update title and send to success screen, otherwise do nothing
            let match: Bool = submitYayRequest()
            if match {
                model.finalDecisionTitle = model.currentSuggestion.name
                self.hasFoundMatch = true
            } else {
                model.updateSuggestion()
                return
            }
        }
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
    let usernameUrlString = "https://us-east1-lets-eat-303301.cloudfunctions.net/login"
    let groupNameUrlString = "https://us-east1-lets-eat-303301.cloudfunctions.net/create_group"
    let getGroupMateUrlString = "https://us-east1-lets-eat-303301.cloudfunctions.net/get-group"
    let submitYayString = "https://us-east1-lets-eat-303301.cloudfunctions.net/Yay"
    
    // MARK - Send Username to login
    func sendLogin(username: String) {
        print("Sending login.")
        let url = URL(string: usernameUrlString)
        
        guard let requestUrl = url else {
            print("Request failed, url inaccessible.")
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["username" : model.username]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let error = error {
                print("Error \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) { // _ is dataString
                print("Login Response: \(dataString)")
            }
        }
        task.resume()
    }
    
    // MARK - Get Reccomendation HTTP Request
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
    
    // MARK - POST Group Name
    func postGroupName() { // group name is really the other person's username for now.
        print("Posting group name.")
        
        let url = URL(string: groupNameUrlString)
        
        guard let requestUrl = url else {
            print("Request failed, url inaccessible.")
            return
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["user" : model.username, "friend" : model.groupName]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if let error = error {
                print("Error \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) { // _ is dataString
                print("Response: \(dataString)")
            }
        }
        task.resume()
    }
    
    // MARK - POST Get Group From Username
    func queryForGroup() { // Given a username, want to get the other user of the group
        print("Getting username of groupmate.")
        
        let url = URL(string: getGroupMateUrlString)
        
        guard let requestUrl = url else {
            print("Request failed, url inaccessible.")
            return
        }
        
        let semaphore = DispatchSemaphore.init(value: 0) // cannot edit model from separate thread so need to wait until request completes before appending to the suggestion queue in model. Probably a better solution, but using this for now.
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["username" : model.username]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        var jsonResp: Data = Data()
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
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
            }
        }
        task.resume()
        
        semaphore.wait()
                
        let ret: GroupQueryJson = try! JSONDecoder().decode(GroupQueryJson.self, from: jsonResp)
        let foundBool: Bool = Bool(ret.found) ?? false
        if foundBool {
            model.groupName = ret.group
        }
    }
    
    // MARK - POST Get Group From Username
    func submitYayRequest() -> Bool { // Given a username, want to get the other user of the group
        print("Sending yay request.")
        
        let url = URL(string: submitYayString)
        
        guard let requestUrl = url else {
            print("Request failed, url inaccessible.")
            return false
        }
        
        let semaphore = DispatchSemaphore.init(value: 0) // cannot edit model from separate thread so need to wait until request completes before appending to the suggestion queue in model. Probably a better solution, but using this for now.
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["group" : model.groupName, "restaurant" : model.currentSuggestion.name]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        var jsonResp: Data = Data()
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
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
            }
        }
        task.resume()
        
        semaphore.wait()
               
        let dataString = String(data: jsonResp, encoding: .utf8)
        print("Group Name \(model.groupName)")
        print(dataString ?? "no value")
        let ret: YayRequestReturnJson = try! JSONDecoder().decode(YayRequestReturnJson.self, from: jsonResp)
        
        return ret.match
    }
    
    struct GroupQueryJson: Decodable {
        var found: String
        var group: String
    }
    
    struct YayRequestReturnJson: Decodable {
        var match: Bool
    }
}
