//
//  SignUpViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject {
    let accountType: UserType
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String?
    @Published var isSigningUp: Bool = false
    @Published var didSignUp: Bool = false
    
    private let db = Firestore.firestore()
    
    init(accountType: UserType) {
        self.accountType = accountType
    }
    
    func signUp() {
        guard !name.isEmpty, !email.isEmpty, !phoneNumber.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        isSigningUp = true
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isSigningUp = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let uid = result?.user.uid {
                    let data: [String: Any] = [
                        "name": self?.name ?? "",
                        "email": self?.email ?? "",
                        "phone": self?.phoneNumber ?? "",
                        "role": self?.accountType.rawValue ?? ""
                    ]
                    self?.db.collection("users").document(uid).setData(data) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self?.errorMessage = error.localizedDescription
                            } else {
                                self?.didSignUp = true
                            }
                        }
                    }
                }
            }
        }
    }
}
