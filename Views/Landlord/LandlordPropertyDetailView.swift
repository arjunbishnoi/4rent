//
//  LandlordPropertyDetailView.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct LandlordPropertyDetailView: View {
    let property: Property
    @EnvironmentObject var viewModel: LandlordHomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var rent: String
    @State private var location: String
    @State private var bedrooms: String
    @State private var isListed: Bool
    
    init(property: Property) {
        self.property = property
        _title = State(initialValue: property.title)
        _description = State(initialValue: property.description)
        _rent = State(initialValue: String(format: "%.0f", property.rent))
        _location = State(initialValue: property.location)
        _bedrooms = State(initialValue: String(property.bedrooms))
        _isListed = State(initialValue: property.status == "listed")
    }
    
    private var requestsForProperty: [Request] {
        viewModel.incomingRequests.filter { $0.propertyID == property.id }
    }
    
    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $title)
            }
            Section(header: Text("Description")) {
                TextField("Description", text: $description)
            }
            Section(header: Text("Rent")) {
                TextField("Rent", text: $rent)
                    .keyboardType(.decimalPad)
            }
            Section(header: Text("Location")) {
                TextField("Location", text: $location)
            }
            Section(header: Text("Bedrooms")) {
                TextField("Bedrooms", text: $bedrooms)
                    .keyboardType(.numberPad)
            }
            Section(header: Text("Status")) {
                Toggle("Listed", isOn: $isListed)
            }
            Section {
                Button("Delete Property", role: .destructive) {
                    viewModel.removeProperty(propertyID: property.id)
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            Section(header: Text("Requests")) {
                ForEach(requestsForProperty, id: \.id) { request in
                    HStack {
                        Text(viewModel.tenantNames[request.tenantID] ?? request.tenantID)
                        Spacer()
                        switch request.status {
                        case .pending:
                            Button("Approve") {
                                viewModel.approveRequest(requestID: request.id)
                                viewModel.getIncomingRequests()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            Button("Deny") {
                                viewModel.denyRequest(requestID: request.id)
                                viewModel.getIncomingRequests()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        case .approved:
                            Text("Approved")
                                .foregroundColor(.green)
                                .bold()
                        case .denied:
                            Text("Denied")
                                .foregroundColor(.red)
                                .bold()
                        case .withdrawn:
                            Text("Cancelled")
                                .foregroundColor(.orange)
                                .bold()
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Edit Property")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Landlord", systemImage: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let updated = Property(
                        id: property.id,
                        landlordID: property.landlordID,
                        status: isListed ? "listed" : "delisted",
                        title: title,
                        description: description,
                        rent: Double(rent) ?? property.rent,
                        imageURLs: property.imageURLs,
                        location: location,
                        bedrooms: Int(bedrooms) ?? property.bedrooms
                    )
                    viewModel.updateProperty(updated)
                }
            }
        }
    }
}
