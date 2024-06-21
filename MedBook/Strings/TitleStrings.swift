//
//  TitleStrings.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation



enum TitleStrings: String, Localizable {
    var tableName: String {
        return "Titles"
    }
    
    case log_in
    case sign_up
    case app_name
    case cancel
    
}

protocol Localizable {
  var tableName: String { get }
  var localized: String { get }
}

extension Localizable where Self: RawRepresentable, Self.RawValue == String {
  var localized: String {
    return rawValue.localized(tableName: tableName)
  }
}


extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
