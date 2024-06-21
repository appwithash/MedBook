//
//  LoginView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM : AuthenticationViewModel
   
    var body: some View {
        GeometryReader{gr in
            ScrollView{
                VStack(alignment : .leading){
                    let welcome = Text(TitleStrings.welcome.localized)
                        .foregroundStyle(.blue)
                    Text("\(welcome)\n\(TitleStrings.login_to_continue.localized)")
                        .font(.title)
                        .bold()
                        .padding(.top,30)
                    TextFieldView(label: .email,placeholder: .email_placeholder, text: $authVM.email,isSecureField : false, error: $authVM.emailError)
                    
                    TextFieldView(label: .password,placeholder: .new_password_placeholder, text: $authVM.password,isSecureField : false, error: $authVM.passwordError)
                    
                    
                    Spacer()
                    
                    Button(TitleStrings.log_in.localized){
                        
                    }
                    .buttonStyle(.solid)
                    .padding(.top)
                    
                    
                    
                }
                .frame(minHeight: gr.size.height)
            }
        }
        .padding(.horizontal)
        .medNavigationBar(.log_in)
    }
}



#Preview {
    NavigationStack{
        LoginView()
            .environmentObject(AuthenticationViewModel())
    }
}
