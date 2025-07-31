//
//  PropertyDetailView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @EnvironmentObject private var viewModel: TenantHomeViewModel
    
    private var isShortlisted: Bool {
        viewModel.shortlistedProperties.contains { $0.propertyID == property.id }
    }
    
    private var existingRequest: Request? {
        viewModel.allRequests.first { $0.propertyID == property.id }
    }
    
    var body: some View {
        ScrollView {
            TabView {
                ForEach(property.imageURLs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
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
                    Text("$\(String(format: "%.0f", property.rent)) / month")
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
            
            VStack(spacing: 12) {
                if let req = existingRequest {
                    HStack {
                        Text("Status: \(req.status.rawValue.capitalized)")
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
            .padding(.bottom)
        }
        .navigationTitle(property.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isShortlisted {
                        viewModel.removeFromShortlistedProperties(propertyID: property.id)
                        viewModel.getAllShortlistedProperties()
                    } else {
                        viewModel.addToShortlistedProperties(propertyID: property.id)
                        viewModel.getAllShortlistedProperties()
                    }
                } label: {
                    Image(systemName: isShortlisted ? "star.fill" : "star")
                }
            }
        }
    }
}
