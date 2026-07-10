//
//  CustomerService.swift
//  DemoApp
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case decodingError(Error)
}

struct TransactionRequest: Encodable {
    let title: String
    let date: String
    let amount: Double
    let category: String
    let beneficiary: String?
    let beneficiaryIban: String?
}

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}

struct CustomerService {
    // da aggiornare se cambia l'indirizzo del server
    static let baseURL = "http://localhost:3000"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    static func login(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            LoginRequest(username: username, password: password)
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(LoginResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    static func fetchCustomerData(token: String) async throws -> APIResponse {
        guard let url = URL(string: "\(baseURL)/data") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
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
        category: String,
        beneficiary: String? = nil,
        beneficiaryIban: String? = nil,
        token: String
    ) async throws -> Transaction {
        guard let url = URL(string: "\(baseURL)/transactions") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Stesso formato usato dal server (es. 2026-07-06T20:00:00+0000)
        let dateString = dateFormatter.string(from: date)

        let body = TransactionRequest(
            title: title,
            date: dateString,
            amount: amount,
            category: category,
            beneficiary: beneficiary,
            beneficiaryIban: beneficiaryIban
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        do {
            return try decoder.decode(Transaction.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
}
