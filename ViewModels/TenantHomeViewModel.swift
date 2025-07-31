//
//  TenantHomeViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class TenantHomeViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var shortlistedProperties: [ShortlistedProperty] = []
    @Published var allRequests: [Request] = []
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    var tenantID: String { Auth.auth().currentUser?.uid ?? "" }
    
    var filteredProperties: [Property] {
        guard !searchQuery.isEmpty else { return properties }
        return properties.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    func getAllProperties() {
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
    
    func getAllShortlistedProperties() {
        isLoading = true
        errorMessage = nil
        db.collection("shortlistedProperties")
            .whereField("tenantID", isEqualTo: tenantID)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        self?.shortlistedProperties = snapshot?.documents.compactMap { doc in
                            let data = doc.data()
                            guard
                                let propertyID = data["propertyID"] as? String,
                                let ts = data["addedOn"] as? Timestamp
                            else { return nil }
                            return ShortlistedProperty(
                                id: doc.documentID,
                                propertyID: propertyID,
                                tenantID: self?.tenantID ?? "",
                                addedOn: ts.dateValue()
                            )
                        } ?? []
                    }
                }
            }
    }
    
    func getAllRequests() {
        isLoading = true
        errorMessage = nil
        db.collection("requests")
            .whereField("tenantID", isEqualTo: tenantID)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    let requests = snapshot?.documents.compactMap { doc -> Request? in
                        let data = doc.data()
                        guard
                            let propertyID = data["propertyID"] as? String,
                            let statusString = data["status"] as? String,
                            let timestamp = data["timestamp"] as? Timestamp,
                            let status = RequestStatus(rawValue: statusString)
                        else { return nil }
                        return Request(
                            id: doc.documentID,
                            propertyID: propertyID,
                            tenantID: self.tenantID,
                            status: status,
                            timestamp: timestamp.dateValue()
                        )
                    } ?? []
                    
                    let deduped = Dictionary(grouping: requests, by: { $0.propertyID })
                        .compactMap { _, reqs in
                            reqs.max(by: { $0.timestamp < $1.timestamp })
                        }
                    
                    self.allRequests = deduped
                }
            }
    }
    
    func addToShortlistedProperties(propertyID: String) {
        let data: [String: Any] = [
            "propertyID": propertyID,
            "tenantID": tenantID,
            "addedOn": FieldValue.serverTimestamp()
        ]
        db.collection("shortlistedProperties").addDocument(data: data)
    }
    
    func removeFromShortlistedProperties(propertyID: String) {
        db.collection("shortlistedProperties")
            .whereField("tenantID", isEqualTo: tenantID)
            .whereField("propertyID", isEqualTo: propertyID)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { $0.reference.delete() }
            }
    }
    
    func toggleShortlist(propertyID: String) {
        if let index = shortlistedProperties.firstIndex(where: { $0.propertyID == propertyID }) {
            shortlistedProperties.remove(at: index)
            removeFromShortlistedProperties(propertyID: propertyID)
        } else {
            let entry = ShortlistedProperty(
                id: UUID().uuidString,
                propertyID: propertyID,
                tenantID: tenantID,
                addedOn: Date()
            )
            shortlistedProperties.append(entry)
            addToShortlistedProperties(propertyID: propertyID)
        }
    }
    
    func sendRequest(propertyID: String) {
        let ref = db.collection("requests")
        ref
            .whereField("tenantID", isEqualTo: tenantID)
            .whereField("propertyID", isEqualTo: propertyID)
            .getDocuments { [weak self] snapshot, _ in
                snapshot?.documents.forEach { $0.reference.delete() }
                
                let data: [String: Any] = [
                    "propertyID": propertyID,
                    "tenantID": self?.tenantID ?? "",
                    "status": RequestStatus.pending.rawValue,
                    "timestamp": FieldValue.serverTimestamp()
                ]
                ref.addDocument(data: data) { _ in
                    DispatchQueue.main.async {
                        self?.getAllRequests()
                    }
                }
            }
    }
    
    func withdrawRequest(requestID: String) {
        db.collection("requests").document(requestID)
            .updateData(["status": RequestStatus.withdrawn.rawValue]) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.getAllRequests()
                }
            }
    }
}
