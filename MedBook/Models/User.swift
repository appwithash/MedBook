//
//  User.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import SwiftUI
import SwiftData

@Model
class User{
    var email : String
    var password : String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
