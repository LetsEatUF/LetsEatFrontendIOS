//  View
//  ContentView.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/29/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                
                Text("Let's Eat!")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .onTapGesture {
                        viewModel.getReccomendations(lat: 12, long: 12)
                    }
                
                PlaceView(viewModel: viewModel)
                
                Spacer()
                
                MenuView()
                
                Spacer()
            }
            
        }
        .foregroundColor(Color.green)
    }
}

struct PlaceView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius:25.0) // BACKGROUND
                .padding()
                .foregroundColor(.white)
            VStack {
                Text(viewModel.getSuggestionName())
                    .font(.largeTitle)
                    .bold()
                    .padding(30)
                Image(uiImage: #imageLiteral(resourceName: "letseat-temp"))
                    .resizable()
                    .padding(.horizontal)
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                Spacer()
                
                Text("lots of info i am typing multiple lines please keep going okay good yes i agree that is very nice are you going to resize now ")
                    .padding(20)
                
                HStack(alignment: .bottom) { // yay or nay?
                    Text("Yay")
                        .bold()
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(40)
                    Spacer()
                    Text("Nay")
                        .bold()
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(40)
                }.padding()
            }
        }.padding()
        .cornerRadius(10)
    }
}

struct MenuView: View {
    var body: some View {
        HStack {
            Text("Menu")
                .foregroundColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ViewModel()
        ContentView(viewModel: vm)
    }
}
