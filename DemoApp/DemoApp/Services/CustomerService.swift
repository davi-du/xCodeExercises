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

struct TransactionRequest: Encodable {
    let title: String
    let date: String
    let amount: Double
    let category: String
}

struct CustomerService {
    //da cambiare ogni volta che sacde
    static let baseURL = "http://localhost:3000"
    
    static func fetchCustomerData() async throws -> APIResponse {
        guard let url = URL(string: "\(baseURL)/data") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
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
    

    static func addTransaction(
        title: String,
        date: Date,
        amount: Double,
        category: String
    ) async throws -> Transaction {
        guard let url = URL(string: "\(baseURL)/transactions") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Formatta la data nello stesso formato usato dal JSON del server (es. 2026-07-06T20:00:00+0000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = formatter.string(from: date)

        let body = TransactionRequest(
            title: title,
            date: dateString,
            amount: amount,
            category: category
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(Transaction.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
}
