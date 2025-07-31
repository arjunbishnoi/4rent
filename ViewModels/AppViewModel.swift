//
//  AppViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

enum Route {
    case login
    case guestHome
    case tenantHome
    case landlordHome
}

class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var currentUserType: UserType?
    @Published var currentRoute: Route = .login
    
    private let db = Firestore.firestore()
    
    func getCurrentUser() {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        let uid = firebaseUser.uid
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let phoneNumber = data["phone"] as? String ?? ""
            let roleString = data["role"] as? String ?? ""
            let userType = UserType(rawValue: roleString) ?? .guest
            let user = User(id: uid, name: name, email: email, phoneNumber: phoneNumber, userType: userType)
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.currentUserType = userType
                self?.isLoggedIn = true
                switch userType {
                case .guest:
                    self?.currentRoute = .guestHome
                case .tenant:
                    self?.currentRoute = .tenantHome
                case .landlord:
                    self?.currentRoute = .landlordHome
                }
            }
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.currentUserType = nil
            self.isLoggedIn = false
            self.currentRoute = .login
        }
    }
}
