//
//  ErrorStrings.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation

enum ErrorStrings: String, Localizable {
    var tableName: String {
        return "Errors"
    }
    
    case email_empty_error
    case email_invalid_error
    
    case password_empty_error
    case password_special_character_error
    case password_uppercase_character_error
    case password_number_character_error
    case password_length_error
    case no_country_selected_error
    
    case user_not_exist
    case user_already_exist
    case wrong_password
}
