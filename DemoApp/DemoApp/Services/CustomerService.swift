//
//  CustomerService.swift
//  DemoApp
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
}

struct CustomerService {
    //da cambiare ogni volta che sacde
    static let baseURL = "https://mocki.io/v1/9bb645c6-3c02-429d-824f-0fb058309900"
    
    static func fetchCustomerData() async throws -> APIResponse {
        guard let url = URL(string: baseURL) else { 
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code ricevuto: \(httpResponse.statusCode)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(APIResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
}
