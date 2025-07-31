//
//  ShortlistedProperty.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation

struct ShortlistedProperty: Identifiable, Codable {
    let id: String
    let propertyID: String
    let tenantID: String
    let addedOn: Date
}

