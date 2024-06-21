//
//  CountryModel.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation
import SwiftData

@Model
final class CountryModel : Identifiable{
    var country : String
    var region : String
    var id : String{
        return country
    }
    init(country: String, region: String) {
        self.country = country
        self.region = region
    }
}
