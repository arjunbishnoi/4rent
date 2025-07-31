//
//  Request.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation

enum RequestStatus: String, Codable {
    case pending
    case approved
    case denied
    case withdrawn
}

struct Request: Identifiable, Codable {
    let id: String
    let propertyID: String
    let tenantID: String
    let status: RequestStatus
    let timestamp: Date
}
