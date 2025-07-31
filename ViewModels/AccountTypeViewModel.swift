//
//  AccountTypeViewModel.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import Foundation
import Combine

class AccountTypeViewModel: ObservableObject {
    @Published var selectedType: UserType?
    @Published var navigateToSignUp: Bool = false
    @Published var showGuestHome: Bool = false
    
    func goNext() {
        guard let type = selectedType else { return }
        if type == .guest {
            showGuestHome = true
        } else {
            navigateToSignUp = true
        }
    }
}
