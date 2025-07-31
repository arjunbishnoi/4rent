//
//  PropertyCardView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct PropertyCardView: View {
    let property: Property
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: property.imageURLs.first ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    Color.gray.overlay(Image(systemName: "photo"))
                default:
                    ProgressView()
                }
            }
            .frame(width: 90, height: 90)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(property.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(property.bedrooms) bd")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(property.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("$\(property.rent, specifier: "%.0f") / mo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
