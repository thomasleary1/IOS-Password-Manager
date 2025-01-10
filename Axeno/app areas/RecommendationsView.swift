//
//  RecommendationsView.swift
//  Axeno
//
//  Created by Thomas Leary on 28/9/2024.
//

import SwiftUI

// ViewModel to provide general password recommendations
class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [String] = []
    @Published var errorMessage: String = ""

    func provideRecommendations() {
        // General recommendations for strong passwords
        recommendations = [
            "Use at least 12 characters in your passwords.",
            "Include a mix of upper and lower case letters.",
            "Add numbers and special characters.",
            "Avoid using easily guessed information like birthdays or names.",
            "Consider using a passphrase that combines several random words."
        ]
    }
}

// Main View
struct RecommendationsView: View {
    @StateObject private var viewModel = RecommendationsViewModel()

    var body: some View {
        VStack {
            Text("Password Recommendations")
                .font(.largeTitle)
                .padding()

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            List(viewModel.recommendations, id: \.self) { recommendation in
                Text(recommendation)
            }
        }
        .onAppear {
            viewModel.provideRecommendations()
        }
    }
}
