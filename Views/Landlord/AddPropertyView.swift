//
//  AddProperty.swift
//  4rent
//
//  Created by Arjun Bishnoi on 2025-07-10.
//

import SwiftUI

struct AddPropertyView: View {
    var onSave: (Property) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var rent = ""
    @State private var location = ""
    @State private var imageURL = ""
    @State private var bedrooms = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Rent (numeric)", text: $rent)
                        .keyboardType(.decimalPad)
                    TextField("Location", text: $location)
                    TextField("Bedrooms (numeric)", text: $bedrooms)
                        .keyboardType(.numberPad)
                }
                Section("Image URL") {
                    TextField("Image URL", text: $imageURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("New Listing")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard
                            let rentValue = Double(rent),
                            let bedroomsValue = Int(bedrooms),
                            !title.isEmpty,
                            !description.isEmpty,
                            !location.isEmpty,
                            !imageURL.isEmpty
                        else { return }
                        let newProp = Property(
                            id: UUID().uuidString,
                            landlordID: "",
                            title: title,
                            description: description,
                            rent: rentValue,
                            imageURLs: [imageURL],
                            location: location,
                            bedrooms: bedroomsValue
                        )
                        onSave(newProp)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
