//
//  ProfileView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var appVM: AppViewModel
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Account Type").font(.headline)) {
                    Text(viewModel.accountType.capitalized)
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Name").font(.headline)) {
                    TextField("Name", text: $viewModel.name)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("Email").font(.headline)) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Phone Number").font(.headline)) {
                    TextField("Phone Number", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                if let error = viewModel.errorMessage {
                    Section(header: Text("Error").font(.headline)) {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    viewModel.saveProfile()
                }) {
                    Text(viewModel.isSaving ? "Saving..." : "Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isSaving)
                
                Button(action: {
                    appVM.logout()
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadProfile()
        }
    }
}
