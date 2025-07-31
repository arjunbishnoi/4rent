//  AccountTypeView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.
//
import SwiftUI

struct AccountTypeView: View {
    @StateObject private var viewModel = AccountTypeViewModel()
    
    private let options: [UserType] = [.guest, .tenant, .landlord]
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Select your account type:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 15)
                
                VStack(spacing: 10) {
                    ForEach(options, id: \.self) { type in
                        Button(action: {
                            viewModel.selectedType = type
                        }) {
                            HStack {
                                Image(systemName: viewModel.selectedType == type ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                Text(type.rawValue.capitalized)
                                    .font(.title2)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                
                Spacer()
                
                Button(action: {
                    viewModel.goNext()
                }) {
                    Text("Next")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedType != nil ? Color.black : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.selectedType == nil)
                .padding(.horizontal, 30)
                
                NavigationLink(
                    destination: SignUpView(userRole: viewModel.selectedType?.rawValue.capitalized ?? ""),
                    isActive: $viewModel.navigateToSignUp
                ) {
                    EmptyView()
                }
            }
            .fullScreenCover(isPresented: $viewModel.showGuestHome) {
                GuestHomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
