//
//  MasterPasswordView.swift
//  Axeno
//
//  Created by Thomas Leary on 25/9/2024.
//

import SwiftUI

struct SignupRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct MasterPasswordView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var name: String
    var email: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Master Password")
                .font(.largeTitle)
            
            SecureField("Master Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
   
            Text("Password must be at least 10 characters long")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.top, 5)
            
            Button(action: signupUser) {
                Text("Signup")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(password.isEmpty || confirmPassword.isEmpty || password != confirmPassword || password.count < 10)
        }
        .padding()
    }
    
    func signupUser() {
        guard password == confirmPassword else {
            print("Passwords do not match")
            return
        }
        
        let signupData = SignupRequest(
            name: name,
            email: email,
            password: password
        )
        
        sendSignupRequest(signupData: signupData)
    }
    
    func sendSignupRequest(signupData: SignupRequest) {
        guard let url = URL(string: "http://1.1.1.1:3000/signup") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(signupData)
            request.httpBody = jsonData
        } catch {
            print("Error encoding signup data: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("No response or data")
                return
            }
            
            if response.statusCode == 200 {
                print("Signup successful")
            } else {
                print("Signup failed: \(response.statusCode)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Response data: \(dataString)")
                }
            }
        }
        
        task.resume()
    }
}
