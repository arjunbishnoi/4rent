//
//  LandlordHomeView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.

import SwiftUI

struct LandlordHomeView: View {
    @StateObject private var viewModel = LandlordHomeViewModel()
    @State private var showAddProperty = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                myListingsTab
                    .tabItem { Label("My Listings", systemImage: "list.bullet") }
                
                requestsTab
                    .tabItem { Label("Requests", systemImage: "envelope") }
                
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
            }
            .navigationTitle("Landlord")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddProperty = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.getMyProperties()
            }
            .sheet(isPresented: $showAddProperty) {
                AddPropertyView { newProperty in
                    viewModel.addProperty(newProperty)
                    showAddProperty = false
                }
            }
        }
        .environmentObject(viewModel)
    }
    
    private var myListingsTab: some View {
        List(viewModel.myProperties, id: \.id) { property in
            NavigationLink {
                LandlordPropertyDetailView(property: property)
            } label: {
                PropertyCardView(property: property)
            }
        }
        .listStyle(.plain)
    }
    
    private var requestsTab: some View {
        List {
            ForEach(viewModel.incomingRequests, id: \.id) { request in
                if let property = viewModel.myProperties.first(where: { $0.id == request.propertyID }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(viewModel.tenantNames[request.tenantID] ?? request.tenantID) requested for \"\(property.title)\"")
                            .font(.subheadline)
                            .padding(.vertical, 4)
                        
                        HStack {
                            switch request.status {
                            case .pending:
                                Button("Approve") {
                                    viewModel.approveRequest(requestID: request.id)
                                    viewModel.getIncomingRequests()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                
                                Button("Deny") {
                                    viewModel.denyRequest(requestID: request.id)
                                    viewModel.getIncomingRequests()
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                                
                            case .approved:
                                Text("Approved")
                                    .foregroundColor(.green)
                                    .bold()
                                
                            case .denied:
                                Text("Denied")
                                    .foregroundColor(.red)
                                    .bold()
                                
                            case .withdrawn:
                                Text("Cancelled")
                                    .foregroundColor(.orange)
                                    .bold()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .listRowSeparator(.visible)
        }
        .listStyle(.plain)
    }
}
