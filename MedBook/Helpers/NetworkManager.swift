//
//  NetworkManager.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchData<T: Decodable>(with url : URLStrings) async throws -> T{
        guard let url = URL(string: url.localized) else{
            throw MedBookError.invalidURL
        }
        
        let urlRequest = URLRequest(url: url)
       
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MedBookError.invalidData
        }
        let decodedData = try JSONDecoder().decode(T.self, from: data)

        return decodedData
    }
}


enum MedBookError : Error{
    case invalidURL
    case noDataFound
    case invalidData
}
