//
//  ContentView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct ContentView: View {
    @State var showSplashScreen = true
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack{
            VStack {
                if self.showSplashScreen == true{
                    SplashScreenView()
                }else{
                    if UserDefaultManager.shared.isLoggedIn{
                        HomeScreenView(context: context)
                    }else{
                        LandingPageView()
                    }
                }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                    self.showSplashScreen = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
