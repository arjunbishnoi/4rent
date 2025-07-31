//
//  LoginViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var rememberMe: Bool = false
    @Published var isLoggingIn: Bool = false
    @Published var errorMessage: String?
    @Published var didLogin: Bool = false
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and Password cannot be empty."
            return
        }
        isLoggingIn = true
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoggingIn = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    if self?.rememberMe == true {
                        UserDefaults.standard.set(self?.email, forKey: "savedEmail")
                        UserDefaults.standard.set(self?.password, forKey: "savedPassword")
                    } else {
                        UserDefaults.standard.removeObject(forKey: "savedEmail")
                        UserDefaults.standard.removeObject(forKey: "savedPassword")
                    }
                    self?.didLogin = true
                }
            }
        }
    }
}
