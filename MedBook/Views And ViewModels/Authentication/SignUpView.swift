//
//  SignUpView.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM : AuthenticationViewModel
   
    var body: some View {
        ScrollView{
            VStack(alignment : .leading){
                let welcome = Text(TitleStrings.welcome.localized)
                    .foregroundStyle(.blue)
                Text("\(welcome)\n\(TitleStrings.signup_to_continue.localized)")
                    .font(.title)
                    .bold()
                    .padding(.top,30)
                TextFieldView(label: .email,placeholder: .email_placeholder, text: $authVM.email,isSecureField : false, error: $authVM.emailError)
                
                TextFieldView(label: .password,placeholder: .new_password_placeholder, text: $authVM.password,isSecureField : false, error: $authVM.passwordError)
                
                HStack{
                    Text(TitleStrings.select_country.localized)
                        .foregroundColor(Color(.systemGray3))
                    Spacer()
                    
                    Picker("", selection: $authVM.selectedCountry) {
                        ForEach(Array(self.authVM.countryList.values.sorted(by: {$0.country < $1.country}))){ country in
                            Text(country.country)
                                .tag(country)
                            
                        }
                    }
                }
                .padding(.vertical,10)
                .padding(.horizontal)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(.systemGray4),lineWidth: 1))
                .padding(.top)
                
                Spacer()
                
                Button(TitleStrings.sign_up.localized){
                    
                }
                .buttonStyle(.solid)
                .padding(.top)
                
                
                
            }
        }
        .padding(.horizontal)
        .medNavigationBar(.sign_up)
    }
}


struct TextFieldView : View {
    var label : TitleStrings? = nil
    var placeholder : TitleStrings
    @Binding var text : String
    @State var isSecureField : Bool
    @FocusState var inFocus : Bool
    @State var showPassword = false
    var borderColor : Color{
        return inFocus ? Color.blue : Color(.systemGray4)
    }
    @Binding var error : String?
    var body: some View {
        VStack(alignment: .leading,spacing: 5){
            if let label = label {
                Text(label.localized)
                    .foregroundColor(Color.gray)
                    .padding(.top, 10)
                
            }
            
            HStack(spacing:20) {
                VStack(alignment: .leading) {
                    
                    if isSecureField {
                        SecureField(placeholder.localized, text: $text)
                            .focused($inFocus)
                    } else {
                        TextField(placeholder.localized, text: $text)
                            .focused($inFocus)
                            .keyboardType(.alphabet)
                            .autocorrectionDisabled()
                    }
                }
                
                Spacer()
                if self.isSecureField == true{
                    Image(systemName: self.showPassword ? "eye" : "eye.slash")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.isSecureField.toggle()
                        }
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(borderColor,lineWidth: 1))
            
            if let error = error {
                Text(error)
                    .foregroundColor(Color.red)
            }
           
        }
       
       
    }
}
#Preview {
    NavigationView{
        SignUpView()
            .environmentObject(AuthenticationViewModel())
    }
}
