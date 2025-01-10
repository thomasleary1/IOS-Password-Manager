//
//  PasswordsView.swift
//  Axeno
//
//  Created by Thomas Leary on 28/9/2024.
//

import SwiftUI

struct AddPasswordView: View {
    @State private var website: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Add Password")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            TextField("Website", text: $website)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Button(action: savePassword) {
                Text("Save Password")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(website.isEmpty || email.isEmpty || password.isEmpty)
        }
        .padding()
    }
    
    private func getCurrentUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "currentUserId")
    }
    
    private func savePassword() {
        guard let userId = getCurrentUserId() else {
            errorMessage = "User is not logged in."
            return
        }
        
        // Save to Keychain
        let keychainService = "YourAppName"
        let success = KeychainHelper.savePassword(service: keychainService, account: email, password: password)
        
        if !success {
            errorMessage = "Failed to save password to Keychain."
            return
        }
        
        // Explicitly specify the type of passwordData
        let passwordData: [String: Any] = [
            "userId": userId,
            "website": website,
            "email": email,
            "password": password
        ]
        
        guard let url = URL(string: "http://1.1.1.1:3000/api/passwords") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: passwordData, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = "Request failed: \(error)"
                    }
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        errorMessage = "Invalid response"
                    }
                    return
                }
                
                if response.statusCode == 201 {
                    DispatchQueue.main.async {
                        errorMessage = ""
                        successMessage = "Password saved successfully!"
                        website = ""
                        email = ""
                        password = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Failed to save password: \(response.statusCode)"
                    }
                }
            }
            
            task.resume()
        } catch {
            errorMessage = "Error serializing JSON: \(error)"
        }
    }
}
