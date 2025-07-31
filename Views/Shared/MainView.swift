//
//  MainView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-09.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appVM: AppViewModel
    var body: some View {
        Group {
            switch appVM.currentRoute {
            case .login:
                LoginView()
            case .guestHome:
                GuestHomeView()
            case .tenantHome:
                TenantHomeView()
            case .landlordHome:
                LandlordHomeView()
            }
        }
        .onAppear {
            appVM.getCurrentUser()
        }
    }
}
