//
//  SplashScreenView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack{
            Color
                .blue.ignoresSafeArea()
            VStack{
                Text(TitleStrings.app_name.localized)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                
                Image(.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.8)
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
