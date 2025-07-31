//  LoginView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appVM: AppViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("4Rent")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Email", text: $viewModel.email)
                            .padding(.vertical, 10)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray),
                                alignment: .bottom
                            )
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding(.vertical, 10)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray),
                                alignment: .bottom
                            )
                    }
                    
                    Toggle("Stay Logged In", isOn: $viewModel.rememberMe)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Group {
                            if viewModel.isLoggingIn {
                                ProgressView()
                            } else {
                                Text("Log In")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoggingIn)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // TODO: handle forgot password
                        }) {
                            Text("Forgot Password?")
                                .underline()
                        }
                    }
                }
                .padding(.top, 80)
                .padding(.horizontal, 30)
                
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Don't have an account yet?")
                    
                    NavigationLink(destination: AccountTypeView()) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        appVM.currentRoute = .guestHome
                    }) {
                        Text("Continue as Guest")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 30)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onChange(of: viewModel.didLogin) { success in
                if success {
                    appVM.getCurrentUser()
                }
            }
        }
    }
}
