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

// MARK: - DailyProgressRing
struct DailyProgressRing: View {
    let progress: Double  // Expected range: 0.0 to 1.0
    let ringColor: Color
    var size: CGFloat = 120
    var lineWidth: CGFloat = 10
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)
            // Foreground progress ring
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
        }
    }
}

// MARK: - MealRowView (Reusable for Meal Rows)
struct MealRowView: View {
    let iconName: String
    let mealName: String
    let currentCalories: Int
    let totalCalories: Int
    
    // Calculate progress for the meal's consumption
    var progress: Double {
        guard totalCalories > 0 else { return 0 }
        return min(Double(currentCalories) / Double(totalCalories), 1.0)
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.green)
            Text(mealName)
                .font(.headline)
            Spacer()
            Text("\(currentCalories)/\(totalCalories) Cal")
                .font(.subheadline)
            ProgressRing(progress: progress)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ProgressRing (Reusable for Meal Rows)
struct ProgressRing: View {
    let progress: Double  // Expected range: 0.0 to 1.0
    var lineWidth: CGFloat = 4
    var size: CGFloat = 24
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: lineWidth)
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
        }
    }
}
