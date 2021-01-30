//
//  LetsEatApp.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/29/21.
//

import SwiftUI

@main
struct LetsEatApp: App {
    var body: some Scene {
        WindowGroup {
            let vm = ViewModel()
            ContentView(viewModel: vm).onAppear(perform: {
                vm.getReccomendations(lat: vm.getLat(), long: vm.getLong())
            })
        }
    }
}
