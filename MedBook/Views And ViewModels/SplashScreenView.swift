//
//  SplashScreenView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack{
            Color
                .blue.ignoresSafeArea()
            VStack{
                Text(TitleStrings.app_name.localized)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.8)
                    .foregroundStyle(.white)
                
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
