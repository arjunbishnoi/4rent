//
//  LandloreHomeViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class LandlordHomeViewModel: ObservableObject {
    @Published var myProperties: [Property] = []
    @Published var incomingRequests: [Request] = []
    @Published var tenantNames: [String: String] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var landlordID: String { Auth.auth().currentUser?.uid ?? "" }
    
    func getMyProperties() {
        isLoading = true
        errorMessage = nil
        let id = landlordID
        db.collection("properties")
            .whereField("landlordID", isEqualTo: id)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.myProperties = snapshot?.documents.compactMap { doc in
                            let data = doc.data()
                            guard
                                let title = data["title"] as? String,
                                let description = data["description"] as? String,
                                let rent = data["rent"] as? Double,
                                let imageURLs = data["imageURLs"] as? [String],
                                let location = data["location"] as? String,
                                let bedrooms = data["bedrooms"] as? Int,
                                let status = data["status"] as? String
                            else { return nil }
                            return Property(
                                id: doc.documentID,
                                landlordID: id,
                                status: status,
                                title: title,
                                description: description,
                                rent: rent,
                                imageURLs: imageURLs,
                                location: location,
                                bedrooms: bedrooms
                            )
                        } ?? []
                        self.getIncomingRequests()
                    }
                }
            }
    }
    
    func getIncomingRequests() {
        isLoading = true
        errorMessage = nil
        db.collection("requests")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    let fetchedRequests: [Request] = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        guard
                            let propertyID = data["propertyID"] as? String,
                            let tenantID = data["tenantID"] as? String,
                            let statusString = data["status"] as? String,
                            let timestamp = data["timestamp"] as? Timestamp,
                            let status = RequestStatus(rawValue: statusString)
                        else { return nil }
                        return Request(
                            id: doc.documentID,
                            propertyID: propertyID,
                            tenantID: tenantID,
                            status: status,
                            timestamp: timestamp.dateValue()
                        )
                    } ?? []
                    self.incomingRequests = fetchedRequests.filter { request in
                        self.myProperties.contains { $0.id == request.propertyID }
                    }
                    let uniqueTenantIDs = Set(self.incomingRequests.map { $0.tenantID })
                    uniqueTenantIDs.forEach { self.fetchTenantName($0) }
                }
            }
    }
    
    private func fetchTenantName(_ id: String) {
        db.collection("users").document(id).getDocument { [weak self] snapshot, error in
            guard
                let self = self,
                error == nil,
                let data = snapshot?.data(),
                let name = data["name"] as? String
            else { return }
            DispatchQueue.main.async {
                self.tenantNames[id] = name
            }
        }
    }
    
    func addProperty(_ property: Property) {
        let data: [String: Any] = [
            "title": property.title,
            "description": property.description,
            "rent": property.rent,
            "imageURLs": property.imageURLs,
            "location": property.location,
            "bedrooms": property.bedrooms,
            "status": property.status,
            "landlordID": landlordID
        ]
        db.collection("properties").addDocument(data: data) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.getMyProperties()
                }
            }
        }
    }
    
    func updateProperty(_ property: Property) {
        let data: [String: Any] = [
            "title": property.title,
            "description": property.description,
            "rent": property.rent,
            "imageURLs": property.imageURLs,
            "location": property.location,
            "bedrooms": property.bedrooms,
            "status": property.status
        ]
        db.collection("properties").document(property.id).updateData(data) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.getMyProperties()
                }
            }
        }
    }
    
    func removeProperty(propertyID: String) {
        db.collection("properties").document(propertyID).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.getMyProperties()
                }
            }
        }
    }
    
    func approveRequest(requestID: String) {
        db.collection("requests").document(requestID)
            .updateData(["status": RequestStatus.approved.rawValue])
    }
    
    func denyRequest(requestID: String) {
        db.collection("requests").document(requestID)
            .updateData(["status": RequestStatus.denied.rawValue])
    }
}
