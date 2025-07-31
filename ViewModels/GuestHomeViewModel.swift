//
//  GuestHomeViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseFirestore

class GuestHomeViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    var filteredProperties: [Property] {
        guard !searchQuery.isEmpty else { return properties }
        return properties.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    func getProperties() {
        isLoading = true
        errorMessage = nil
        db.collection("properties")
            .whereField("status", isEqualTo: "listed")
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        self?.properties = snapshot?.documents.compactMap { doc in
                            let data = doc.data()
                            guard
                                let title = data["title"] as? String,
                                let description = data["description"] as? String,
                                let rent = data["rent"] as? Double,
                                let imageURLs = data["imageURLs"] as? [String],
                                let location = data["location"] as? String,
                                let landlordID = data["landlordID"] as? String,
                                let bedrooms = data["bedrooms"] as? Int,
                                let status = data["status"] as? String
                            else { return nil }
                            return Property(
                                id: doc.documentID,
                                landlordID: landlordID,
                                status: status,
                                title: title,
                                description: description,
                                rent: rent,
                                imageURLs: imageURLs,
                                location: location,
                                bedrooms: bedrooms
                            )
                        } ?? []
                    }
                }
            }
    }
}
