//
//  AccountManagementView.swift
//  Axeno
//
//  Created by Thomas Leary on 28/9/2024.
//

import SwiftUI

struct AccountManagementView: View {
    @State private var userName: String = "Loading..."
    @State private var userEmail: String = "Loading..."
    @State private var showChangePasswordView: Bool = false
    @State private var showDeleteAccountConfirmation: Bool = false
    @State private var showChangeEmailView: Bool = false
    @State private var showChangeNameView: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("Account Management")
                    .font(.largeTitle)
                    .padding(.bottom, 20)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                } else {
                    Text("Name: \(userName)")
                        .font(.title2)
                        .padding(.bottom, 10)

                    Text("Email: \(userEmail)")
                        .font(.title2)
                        .padding(.bottom, 30)
                }

                Button(action: {
                    showChangePasswordView.toggle()
                }) {
                    Text("Change Master Password")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showChangePasswordView) {
                    ChangePasswordView()
                }
                .padding(.bottom, 10)

                Button(action: {
                    showChangeNameView.toggle()
                }) {
                    Text("Change Name")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showChangeNameView) {
                    ChangeNameView(currentName: $userName)
                }
                .padding(.bottom, 10)

                Button(action: {
                    showChangeEmailView.toggle()
                }) {
                    Text("Change Email")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showChangeEmailView) {
                    ChangeEmailView(currentEmail: $userEmail)
                }
                .padding(.bottom, 20)

                Button(action: {
                    showDeleteAccountConfirmation.toggle()
                }) {
                    Text("Delete Account")
                        .font(.title2)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(10)
                }
                .alert(isPresented: $showDeleteAccountConfirmation) {
                    Alert(title: Text("Confirm Deletion"),
                          message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                          primaryButton: .destructive(Text("Delete")) {
                              deleteAccount()
                          },
                          secondaryButton: .cancel())
                }
            }
            .padding()
            .onAppear {
                fetchUserDetails()
            }
        }
    }

    private func fetchUserDetails() {
        guard let userId = getCurrentUserId() else {
            errorMessage = "User is not logged in."
            return
        }

        // Prepare the request to fetch user details
        let url = URL(string: "http://1.1.1.1:3000/user-details?userId=\(userId)")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Failed to fetch user details: \(error)"
                }
                return
            }

            guard let data = data else { return }

            do {
                if let userDetails = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let name = userDetails["name"] as? String, let email = userDetails["email"] as? String {
                        DispatchQueue.main.async {
                            userName = name
                            userEmail = email
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response: \(error)"
                }
            }
        }

        task.resume()
    }

    private func deleteAccount() {
        guard let userId = getCurrentUserId() else {
            print("User is not logged in.")
            return
        }

        // Prepare the request to delete the account
        let url = URL(string: "http://1.1.1.1:3000/delete-account")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let message = responseJson?["message"] as? String {
                    print(message) // Handle success message accordingly
                }
            } catch {
                print("Failed to decode response: \(error)")
            }
        }

        task.resume()
    }

    private func getCurrentUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "currentUserId")
    }
}
