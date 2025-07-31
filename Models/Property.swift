//
//  Property.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation

struct Property: Identifiable, Codable {
    var id: String = UUID().uuidString
    var landlordID: String
    var status: String = "listed"
    var title: String
    var description: String
    var rent: Double
    var imageURLs: [String]
    var location: String
    var bedrooms: Int
}
