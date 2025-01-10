//
//  LoginView.swift
//  Axeno
//
//  Created by Thomas Leary on 25/9/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)

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

                Button(action: loginUser) {
                    Text("Login")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(email.isEmpty || password.isEmpty)

            
                .navigationDestination(isPresented: $isLoggedIn) {
                    DashboardView()
                }
            }
            .padding()
        }
    }

    func loginUser() {
        guard let url = URL(string: "http://1.1.1.1:3000/login") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            errorMessage = "Error encoding data: \(error)"
            return
        }
        
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
            
            if response.statusCode == 200, let data = data {
                DispatchQueue.main.async {
                    errorMessage = ""
                   
                    if let userId = try? JSONDecoder().decode(UserResponse.self, from: data).id {
                        UserDefaults.standard.set(userId, forKey: "currentUserId")
                    }
                    isLoggedIn = true
                    print("Login successful")
                }
            } else if response.statusCode == 401 {
                DispatchQueue.main.async {
                    errorMessage = "Invalid email or password"
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Unexpected error: \(response.statusCode)"
                }
            }
        }
        
        task.resume()
    }
}


struct UserResponse: Codable {
    let id: Int
}
