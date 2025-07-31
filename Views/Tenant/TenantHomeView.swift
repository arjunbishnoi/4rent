//
//  TenantHomeView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-07.
//

import SwiftUI

struct TenantHomeView: View {
    @StateObject private var viewModel = TenantHomeViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Tab = .browse
    @State private var showDeleteAlert = false
    @State private var propertyToDelete: Property?
    
    enum Tab {
        case browse, shortlist, requests, profile
    }
    
    private var navigationTitle: String {
        switch selectedTab {
        case .browse:    return "Browse"
        case .shortlist: return "Shortlist"
        case .requests:  return "Requests"
        case .profile:   return "Profile"
        }
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                browseTab
                    .tabItem { Label("Browse", systemImage: "magnifyingglass") }
                    .tag(Tab.browse)
                
                shortlistTab
                    .tabItem { Label("Shortlist", systemImage: "star") }
                    .tag(Tab.shortlist)
                
                requestsTab
                    .tabItem { Label("Requests", systemImage: "envelope") }
                    .tag(Tab.requests)
                
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(Tab.profile)
            }
            .navigationTitle(navigationTitle)
            .onAppear {
                viewModel.getAllProperties()
                viewModel.getAllShortlistedProperties()
                viewModel.getAllRequests()
            }
            .alert("Delete \(propertyToDelete?.title ?? "property")?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let prop = propertyToDelete {
                        viewModel.removeFromShortlistedProperties(propertyID: prop.id)
                        viewModel.getAllShortlistedProperties()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .environmentObject(viewModel)
    }
    
    private var browseTab: some View {
        VStack {
            TextField("Search properties...", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            if viewModel.isLoading {
                Spacer(); ProgressView(); Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                Spacer()
            } else {
                List(viewModel.filteredProperties, id: \.id) { property in
                    NavigationLink {
                        TenantPropertyDetailView(property: property)
                    } label: {
                        PropertyCardView(property: property)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var shortlistTab: some View {
        let shortlisted = viewModel.properties.filter { prop in
            viewModel.shortlistedProperties.contains { $0.propertyID == prop.id }
        }
        return List(shortlisted, id: \.id) { property in
            PropertyCardView(property: property)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        propertyToDelete = property
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(.plain)
    }
    
    private var requestsTab: some View {
        let requests = viewModel.allRequests.filter {
            $0.status == .pending || $0.status == .denied
        }
        return List(requests, id: \.id) { request in
            if let property = viewModel.properties.first(where: { $0.id == request.propertyID }) {
                VStack(alignment: .leading, spacing: 8) {
                    PropertyCardView(property: property)
                    statusView(for: request.status)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func statusView(for status: RequestStatus) -> some View {
        switch status {
        case .pending:
            Text("Pending")
                .font(.headline)
                .foregroundColor(.orange)
        case .approved:
            Text("Approved")
                .font(.headline)
                .foregroundColor(.green)
        case .denied:
            Text("Denied")
                .font(.headline)
                .foregroundColor(.red)
        default:
            Text(status.rawValue.capitalized)
                .font(.headline)
        }
    }
}
