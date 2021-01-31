//  View
//  ContentView.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/29/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        viewModel.startLoadingScreen()
    }
    
    var body: some View {
        if viewModel.getIsLoading() {
            LoadingView()
        }
        else if viewModel.getIsWaitingForUsername() {
            LoginView(viewModel: viewModel)
        }
        else {
            MainView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ViewModel()
        ContentView(viewModel: vm)
    }
}
