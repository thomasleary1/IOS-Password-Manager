//
//  SearchView.swift
//  Axeno
//
//  Created by Thomas Leary on 28/9/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var filteredPasswords: [PasswordEntry] = []
    @State private var allPasswords: [PasswordEntry] = [] 
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: searchText) {
                    performSearch()
                }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if filteredPasswords.isEmpty && searchText.isEmpty {
                Text("Start typing to search for passwords")
                    .foregroundColor(.gray)
                    .padding()
            } else if filteredPasswords.isEmpty && !searchText.isEmpty {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(filteredPasswords) { password in
                    VStack(alignment: .leading) {
                        Text("Website: \(password.website)")
                            .font(.headline)
                        Text("Email: \(password.email)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: fetchPasswords)
    }
    
    // Fetch passwords from your server
    private func fetchPasswords() {
        guard let userId = getCurrentUserId() else {
            errorMessage = "User is not logged in."
            return
        }
        
        guard let url = URL(string: "http://1.1.1.1/api/passwords/all/\(userId)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Request failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let fetchedPasswords = try JSONDecoder().decode([PasswordEntry].self, from: data)
                DispatchQueue.main.async {
                    self.allPasswords = fetchedPasswords
                    self.filteredPasswords = fetchedPasswords
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response: \(error)"
                }
            }
        }

        task.resume()
    }
    

    private func performSearch() {
        if searchText.isEmpty {
            filteredPasswords = allPasswords
        } else {
            filteredPasswords = allPasswords.filter { password in
                password.website.localizedCaseInsensitiveContains(searchText) ||
                password.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    

    private func getCurrentUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "currentUserId")
    }
}

struct PasswordEntry: Identifiable, Codable {
    let id: Int
    let website: String
    let email: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case website
        case email
        case createdAt = "created_at"
    }
}
