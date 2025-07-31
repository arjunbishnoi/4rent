//
//  GuestPropertyDetailView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct GuestPropertyDetailView: View {
    let property: Property
    
    private var rentString: String {
        String(format: "%.0f", property.rent)
    }
    
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
                            Color.gray.opacity(0.2)
                                .overlay(Image(systemName: "photo"))
                        @unknown default:
                            Color.gray.opacity(0.2)
                                .overlay(Image(systemName: "photo"))
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
                    Text("$\(rentString) / month")
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
        }
        .navigationTitle(property.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
