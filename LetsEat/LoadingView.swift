//
//  LoadingView.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .ignoresSafeArea(.all)
                .foregroundColor(.white)
            Image(uiImage: #imageLiteral(resourceName: "logo"))
                .resizable()
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .padding(250)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
