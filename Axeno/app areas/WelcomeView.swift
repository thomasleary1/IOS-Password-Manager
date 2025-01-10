//
//  WelcomeView.swift
//  Axeno
//
//  Created by Thomas Leary on 22/9/2024.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                
                NavigationLink(destination: LoginView()) {
                    Text("Login")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: SignupView()) {
                    Text("Signup")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}



#Preview {
    WelcomeView()
}
