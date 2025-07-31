//
//  TenantPropertyDetailView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct TenantPropertyDetailView: View {
    let property: Property
    @EnvironmentObject private var viewModel: TenantHomeViewModel
    
    private var rentText: String {
        String(format: "%.0f", property.rent)
    }
    
    private var isShortlisted: Bool {
        viewModel.shortlistedProperties.contains { $0.propertyID == property.id }
    }
    
    private var pendingRequest: Request? {
        viewModel.allRequests.first { $0.propertyID == property.id && $0.status == .pending }
    }
    
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            TabView {
                ForEach(property.imageURLs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Color.gray.opacity(0.2).overlay(Image(systemName: "photo"))
                        @unknown default:
                            Color.gray.opacity(0.2).overlay(Image(systemName: "photo"))
                        }
                    }
                    .frame(height: 240)
                    .clipped()
                }
            }
            .frame(height: 240)
            .tabViewStyle(.page)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(property.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(property.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(rentText) / month")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(property.bedrooms) bd")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Text("Description")
                    .font(.headline)
                Text(property.description)
                    .font(.body)
            }
            .padding()
            
            Divider()
            
            if let req = pendingRequest {
                HStack {
                    Text("Pending")
                        .font(.subheadline)
                    Spacer()
                    Button("Cancel Request") {
                        viewModel.withdrawRequest(requestID: req.id)
                        viewModel.getAllRequests()
                    }
                }
                .padding(.horizontal)
            } else {
                Button("Send Request") {
                    viewModel.sendRequest(propertyID: property.id)
                    viewModel.getAllRequests()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        }
        .navigationTitle(property.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        viewModel.toggleShortlist(propertyID: property.id)
                    } label: {
                        Image(systemName: isShortlisted ? "star.fill" : "star")
                    }
                    Button {
                        showingShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: [
                "Check out this property: \(property.title)\nLocation: \(property.location)\nRent: $\(rentText)/month\nBedrooms: \(property.bedrooms)\nDescription: \(property.description)"
            ])
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
