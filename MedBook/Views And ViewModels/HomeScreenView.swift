//
//  MainView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        VStack{
            Spacer()
        }
        .medNavigationBar(.home_screen,backIcon: backButtonStyles.none)
    }
}

#Preview {
    NavigationStack{
        HomeScreenView()
    }
}
