//
//  ReusableViews.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import SwiftUI

// MARK: - Custom Text Field
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

// MARK: - Custom Number Field
struct CustomNumberField: View {
    var placeholder: String
    @Binding var value: Int

    var body: some View {
        TextField(placeholder, value: $value, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .multilineTextAlignment(.trailing)
    }
}

// MARK: - Nutrient Row
struct NutrientRow: View {
    var label: String
    @Binding var value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            TextField("0", value: $value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .frame(width: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
