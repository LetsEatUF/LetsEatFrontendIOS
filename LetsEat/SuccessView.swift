//
//  SuccessView.swift
//  LetsEat
//
//  Created by Elijah Springer on 1/30/21.
//

import SwiftUI

struct SuccessView: View {
    var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundColor(.white)
            VStack {
                Text("Match Found!")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.green)
                Image(uiImage: #imageLiteral(resourceName: "checkmark"))
                    .resizable()
                    .padding(40)
                Text(viewModel.getSuccessfulMatchTitle())
                //Text("Successful Match")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.green)
            }
        }
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel: ViewModel = ViewModel()
        SuccessView(viewModel: viewModel)
    }
}
