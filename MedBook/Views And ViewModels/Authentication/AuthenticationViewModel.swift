//
//  AuthenticationViewModel.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import Combine
import SwiftData
import IHProgressHUD

class AuthenticationViewModel : ObservableObject{
    
    @Published var email : String = ""
    
    @Published var emailError : ErrorStrings? = nil
    @Published var password : String = ""
    @Published var passwordError : ErrorStrings? = nil
    @Published var countryError : ErrorStrings? = nil
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
     
        $email  
            .receive(on: RunLoop.main)
            .sink(receiveValue: { passphrase in
                self.emailError = nil
            })
            .store(in: &cancellable)
        
        $password
            .receive(on: RunLoop.main)
            .sink(receiveValue: { passphrase in
                self.passwordError = nil
            })
            .store(in: &cancellable)
        
    }
   
    func validateEmail(){
        if self.email.isEmpty{
            self.emailError = .email_empty_error
            
        }else if String.isValidEmail(email) == false{
            self.emailError = .email_invalid_error
        }
        
    }
    
    func validatePassword(){
        if self.password.isEmpty{
            self.passwordError = .password_empty_error
        }else if self.password.count < 8{
            self.passwordError = .password_length_error
        }else if !self.password.contains(where: {$0.isUppercase}){
            self.passwordError = .password_uppercase_character_error
        }else if !self.password.contains(where: {$0.isNumber}){
            self.passwordError = .password_number_character_error
        }else if !self.password.containsSpecialCharacters{
            self.passwordError = .password_special_character_error
        }
    }
    func validate(isSignUp : Bool) -> Bool{
        self.validateEmail()
        
        if isSignUp{
            
        self.validatePassword()
        }else{
            if self.password.isEmpty{
                self.passwordError = .password_empty_error
            }
        }
        if self.emailError == nil && self.passwordError == nil && self.countryError == nil{
            return true
        }else{
            return false
        }
    }
    func signUp(completionHandler : @escaping () -> ()){
        if self.validate(isSignUp: true){
            IHProgressHUD.show(withStatus: "Sign in...")
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                completionHandler()
                IHProgressHUD.dismiss()
                
            }
        }
    }
    
    func logIn(completionHandler : @escaping () -> ()){
        if self.validate(isSignUp: false){
            IHProgressHUD.show(withStatus: "Log in...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                completionHandler()
                IHProgressHUD.dismiss()
            }
        }
    }
    
   

    
}


enum PasswordValidation : String, Identifiable, CaseIterable{
    var id: String{
        self.rawValue
    }
    case passwordLength = "Password should contain minimum 8 characters"
    case uppercase = "Password should contain minimum 1 uppercase character"
    case number = "Password should contain minimum 1 numeric character"
    case special = "Password should contain minimum 1 special character"
   
}
