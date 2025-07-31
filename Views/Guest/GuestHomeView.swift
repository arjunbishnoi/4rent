//
//  GuestHomeView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.
//

import SwiftUI

struct GuestHomeView: View {
    @StateObject private var viewModel = GuestHomeViewModel()
    @EnvironmentObject var appVM: AppViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search properties...", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else {
                    List(viewModel.filteredProperties, id: \.id) { property in
                        NavigationLink {
                            GuestPropertyDetailView(property: property)
                        } label: {
                            PropertyCardView(property: property)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Browse Properties")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        appVM.currentRoute = .login
                    }
                }
            }
            .onAppear {
                viewModel.getProperties()
            }
        }
    }
}
