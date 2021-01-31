//
//  LoginView.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import SwiftUI

struct LoginView: View {
    var viewModel: ViewModel
        
    @State var username: String = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .ignoresSafeArea(.all)
                .foregroundColor(.white)
            VStack {
                Image(uiImage: #imageLiteral(resourceName: "logo"))
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .padding()
                TextField("Enter Username...", text: $username, onCommit: {
                    viewModel.submitLogin(username: username)
                })
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(150)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ViewModel()
        LoginView(viewModel: vm)
    }
}
