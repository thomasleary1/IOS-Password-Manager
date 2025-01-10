//
//  DashboardView.swift
//  Axeno
//
//  Created by Thomas Leary on 28/9/2024.
//

import SwiftUI

struct DashboardView: View {
    @State private var recentPasswords: [PasswordEntry] = []

    var body: some View {
        TabView {
      
            VStack {
                Text("Welcome to the Dashboard")
                    .font(.largeTitle)
                    .padding()

       
                Text("Recently Added Passwords")
                    .font(.headline)
                    .padding()

                if recentPasswords.isEmpty {
                    Text("No recent passwords available.")
                        .foregroundColor(.gray)
                } else {
                    List(recentPasswords) { password in
                        VStack(alignment: .leading) {
                            Text("Website: \(password.website)")
                                .font(.subheadline)
                            Text("Email: \(password.email)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Created on: \(password.formattedDate)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .onAppear(perform: loadRecentPasswords)
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }

            // Passwords tab
            PasswordsView()
                .tabItem {
                    Image(systemName: "key.fill")
                    Text("Passwords")
                }

            // Search tab
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            // Recommendations tab
            RecommendationsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Recommendations")
                }

            // Account Management tab
            AccountManagementView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Account")
                }
        }
    }


    func loadRecentPasswords() {
        guard let userId = getCurrentUserId() else {
            print("User is not logged in.")
            return
        }

        guard let url = URL(string: "http://1.1.1.1:3000/api/passwords/\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching passwords: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode([PasswordEntry].self, from: data)
                DispatchQueue.main.async {
                    self.recentPasswords = decodedResponse
                }
            } catch {
                print("Failed to decode passwords: \(error)")
            }
        }.resume()
    }

    private func getCurrentUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "currentUserId")
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


        var formattedDate: String {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = dateFormatter.date(from: createdAt) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateStyle = .medium
                displayFormatter.timeStyle = .short
                return displayFormatter.string(from: date)
            }
            return createdAt
        }
    }
}
