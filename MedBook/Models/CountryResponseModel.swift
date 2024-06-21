//
//  CountryResponseModel.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation

struct CountryResponseDataModel: Codable {
    let status: String
    let statusCode: Int
    let version: String
    let access: String
    let total: Int
    let offset: Int
    let limit: Int
    let data: [String: CountryDataModel]
    
    enum CodingKeys: String, CodingKey {
        case status
        case statusCode = "status-code"
        case version
        case access
        case total
        case offset
        case limit
        case data
    }
}

struct CountryDataModel: Codable,Identifiable, Hashable {
    let country: String
    let region: String
    var id : String{
        return country
    }
}
