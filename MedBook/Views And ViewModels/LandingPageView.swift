//
//  LandingPageView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct LandingPageView: View {
    @State var showLoginScreen = false
    @State var showSignUpScreen = false
    @ObservedObject var authVM = AuthenticationViewModel()
    @Environment(\.modelContext) private var context
    var body: some View {
        GeometryReader{gr in
            ZStack{
                VStack{
                    Spacer()
                    Text(TitleStrings.app_name.localized)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.black)
                   
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.blue)
                        .scaleEffect(0.8)
                    
                    Spacer()
                    VStack{
                        Button(TitleStrings.log_in.localized){
                            self.showLoginScreen = true
                        }
                        .buttonStyle(.solid)
                        
                        Button(TitleStrings.sign_up.localized){
                            self.showSignUpScreen = true
                        }
                        .buttonStyle(.stroke)
                    }
                }
                .padding()
                .navigate(using: $showLoginScreen, destination: LoginView(modelContext: context).environmentObject(self.authVM))
                .navigate(using: $showSignUpScreen, destination: SignUpView(modelContext: context).environmentObject(self.authVM))
            }
            
        }
    }
}

#Preview {
    NavigationView{
        LandingPageView(authVM: AuthenticationViewModel())
    }
}
