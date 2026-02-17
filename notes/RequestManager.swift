//
//  RequestManager.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-16.
//

import Foundation
import KeychainAccess

final class RequestManager {
    
    static let shared = RequestManager()
    
    private let keychain = Keychain(service: "com.NotesApp")
    
    private let baseURL = URL(string: "https://notesserver-production-105d.up.railway.app")!
    
    private init() {}
        
    func sendRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let token = try? keychain.get("authToken") else {
            completion(.failure(APIError.missingToken))
            return
        }
        
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        print("Sending Request")
        print("URL:", request.url?.absoluteString ?? "nil")
        print("Method:", request.httpMethod ?? "nil")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response:\n\(jsonString)")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
        
    func sendVoidRequest(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = try? keychain.get("authToken") else {
            completion(.failure(APIError.missingToken))
            return
        }
        
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
            
        }.resume()
    }
    
    enum APIError: Error {
        case missingToken
        case invalidURL
        case noData
    }
}
