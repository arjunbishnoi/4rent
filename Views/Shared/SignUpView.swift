//  SignUpView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.
//

import SwiftUI

struct SignUpView: View {
    let userRole: String
    @StateObject private var viewModel: SignUpViewModel
    @EnvironmentObject var appVM: AppViewModel
    
    init(userRole: String) {
        self.userRole = userRole
        _viewModel = StateObject(wrappedValue: SignUpViewModel(accountType: UserType(rawValue: userRole.lowercased()) ?? .guest))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Create \(userRole) Account")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            VStack(spacing: 20) {
                TextField("Name", text: $viewModel.name)
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                
                TextField("Email", text: $viewModel.email)
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                
                TextField("Phone Number", text: $viewModel.phoneNumber)
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                    .keyboardType(.phonePad)
                
                SecureField("Password", text: $viewModel.password)
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
            }
            .padding(.top, 20)
            .padding(.horizontal, 30)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
            }
            
            Button(action: {
                viewModel.signUp()
            }) {
                Group {
                    if viewModel.isSigningUp {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(viewModel.isSigningUp)
            .padding(.horizontal, 30)
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("Already have an account?")
                Button(action: { viewModel.didSignUp = true }) {
                    Text("Log In")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 30)
            }
            
            NavigationLink(destination: LoginView(), isActive: $viewModel.didSignUp) {
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.didSignUp) { success in
            if success {
                appVM.getCurrentUser()
            }
        }
    }
}
