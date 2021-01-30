//
//  LetsEatViewModel.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import Foundation

class ViewModel: ObservableObject {
    @Published var model: LetsEatModel = LetsEatModel()
    
    // MARK - HTTP Request Functions
    let url = URL(string: "https://let-s-eat-api-gateway-d3f77p7e.ue.gateway.dev/hello")
    
    func testRequest() {
        print("Running test request.")
        
        guard let requestUrl = url else {
            print("Request failed, invalid url.")
            return
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let json: [String: Any] = ["message" : "test"]
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
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response: \(dataString)")
            }
        }
        task.resume()
    }
}
