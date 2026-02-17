//
//  AuthView.swift
//  notes
//
//  Created by Caleb Chiang on 2026-02-16.
//

import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    
    @State private var isLoginMode: Bool = false
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    private let baseURL = "https://notesserver-production-105d.up.railway.app"
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text(isLoginMode ? "Login" : "Sign Up")
                .font(.title)
            
            if !isLoginMode {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                if isLoginMode {
                    handleLogin()
                } else {
                    handleSignup()
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text(isLoginMode ? "Login" : "Sign Up")
                }
            }
            .disabled(isLoading)
            
            Button(action: {
                isLoginMode.toggle()
                errorMessage = nil
            }) {
                Text(isLoginMode ?
                     "Don't have an account? Sign Up" :
                     "Already have an account? Login")
            }
            .padding(.top, 8)
            
        }
        .padding()
    }
    
    // MARK: - Signup
    
    func handleSignup() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/users") else { return }
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                if httpResponse.statusCode == 201 {
                    // After signup, automatically log them in
                    handleLogin()
                } else {
                    errorMessage = "Signup failed"
                }
            }
        }.resume()
    }
    
    // MARK: - Login
    
    func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let token = json["token"] as? String {
                        
                        auth.saveToken(token)
                        
                    } else {
                        errorMessage = "Invalid token response"
                    }
                } else {
                    errorMessage = "Invalid email or password"
                }
            }
        }.resume()
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}

