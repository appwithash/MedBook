//
//  NetworkManager.swift
//  MedBook
//
//  Created by ashutosh on 20/06/24.
//

import Foundation
import Combine
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
    
    func fetchDataWithParameters<T: Decodable>(from urlString: URLStrings, queryParams: [String: String] = [:]) async throws -> T {
        guard var urlComponents = URLComponents(string: urlString.localized) else {
            throw MedBookError.invalidURL
        }

        // Adding query parameters to the URL if any are provided
        if !queryParams.isEmpty {
            var queryItems = [URLQueryItem]()
            for (key, value) in queryParams {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
        }
        guard let url = urlComponents.url else {
            throw MedBookError.invalidURL
        }

        let urlRequest = URLRequest(url: url)
        print("booklist url",urlRequest)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
           
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw MedBookError.invalidData
            }

            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw error
        }
    }

}


enum MedBookError : Error{
    case invalidURL
    case noDataFound
    case invalidData
}
