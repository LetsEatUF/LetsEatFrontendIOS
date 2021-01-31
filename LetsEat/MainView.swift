//
//  MainView.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import SwiftUI

struct MainView: View {
    var viewModel: ViewModel
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
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
                
                MenuView(viewModel: viewModel)
                
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
                
//                Text("lots of info i am typing multiple lines please keep going okay good yes i agree that is very nice are you going to resize now ")
//                    .padding(20)
                
                Text(viewModel.getAddress())
                    .padding(20)
                
                HStack(alignment: .bottom) { // yay or nay?
                    Text("Yay")
                        .bold()
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(40)
                        .onTapGesture {
                            viewModel.submitYay()
                        }
                    Spacer()
                    Text("Nay")
                        .bold()
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding(40)
                        .onTapGesture {
                            viewModel.updateSuggestion()
                        }
                }.padding()
            }
        }.padding()
        .cornerRadius(10)
    }
}

struct MenuView: View {
    var viewModel: ViewModel
    @State var group: String = ""
    
    var body: some View {
        HStack {
            TextField("Enter Username...", text: $group, onCommit: {
                viewModel.submitGroup(groupName: group)
            })
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 150)
        }
    }
}
