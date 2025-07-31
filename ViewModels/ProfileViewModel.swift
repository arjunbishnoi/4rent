//
//  ProfileViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var accountType: String = ""
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false
    @Published var didSave: Bool = false
    
    private let db = Firestore.firestore()
    private var userID: String { Auth.auth().currentUser?.uid ?? "" }
    
    func loadProfile() {
        db.collection("users").document(userID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let data = snapshot?.data(), error == nil {
                    self.name = data["name"] as? String ?? ""
                    self.email = data["email"] as? String ?? ""
                    self.phoneNumber = data["phone"] as? String ?? ""
                    self.accountType = data["role"] as? String ?? ""
                } else {
                    self.errorMessage = error?.localizedDescription
                }
            }
        }
    }
    
    func saveProfile() {
        guard !name.isEmpty, !email.isEmpty, !phoneNumber.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        isSaving = true
        errorMessage = nil
        let data: [String: Any] = [
            "name": name,
            "email": email,
            "phone": phoneNumber,
            "accountType": accountType
        ]
        db.collection("users").document(userID).setData(data, merge: true) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.didSave = true
                }
            }
        }
    }
}
