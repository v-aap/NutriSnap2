//
//  NutritionAnalysisService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class NutritionAnalysisService {
    static let shared = NutritionAnalysisService()
    private let db = Firestore.firestore()

    // MARK: - Fetch User Nutrition Goals
    func fetchUserGoals(completion: @escaping (UserModel?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user!")
            completion(nil)
            return
        }

        db.collection("users").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("❌ Error fetching user goals: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = snapshot?.data(), let user = UserModel.fromFirestore(id: userID, data: data) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - Fetch Meals Logged for a Specific Date
    func fetchMealsForDate(date: Date, completion: @escaping ([MealEntry]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user!")
            completion([])
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        db.collection("meals")
            .whereField("userID", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching meals: \(error.localizedDescription)")
                    completion([])
                    return
                }

                let meals = snapshot?.documents.compactMap { doc -> MealEntry? in
                    MealEntry.fromFirestore(id: doc.documentID, data: doc.data())
                } ?? []
                completion(meals)
            }
    }

    // MARK: - Compare Meals Against Goals
    func analyzeNutrition(for date: Date, completion: @escaping (Int, Int, Int, Int, Int, [MealType: Int]) -> Void) {
        fetchUserGoals { userGoals in
            guard let goals = userGoals else {
                print("❌ No user goals found")
                completion(0, 0, 0, 0, 0, [:])
                return
            }

            self.fetchMealsForDate(date: date) { meals in
                let totalCalories = meals.reduce(0) { $0 + $1.calories }
                let totalCarbs = meals.reduce(0) { $0 + $1.carbs }
                let totalProtein = meals.reduce(0) { $0 + $1.protein }
                let totalFats = meals.reduce(0) { $0 + $1.fats }

                // Calculate meal-based calorie tracking
                var mealCalories: [MealType: Int] = [
                    .breakfast: 0,
                    .lunch: 0,
                    .dinner: 0,
                    .snack: 0
                ]

                meals.forEach { meal in
                    mealCalories[meal.mealType, default: 0] += meal.calories
                }

                print("📊 Comparison Results:")
                print("  ✅ Calories: \(totalCalories)/\(goals.calorieGoal)")
                print("  ✅ Carbs: \(totalCarbs)g (\(goals.carbPercentage)%)")
                print("  ✅ Protein: \(totalProtein)g (\(goals.proteinPercentage)%)")
                print("  ✅ Fats: \(totalFats)g (\(goals.fatPercentage)%)")

                print("📌 Calories per meal:")
                for (mealType, calories) in mealCalories {
                    print("  ✅ \(mealType.rawValue): \(calories) Cal")
                }

                completion(totalCalories, goals.calorieGoal, totalCarbs, totalProtein, totalFats, mealCalories)
            }
        }
    }

    // MARK: - Calculate Meal-Specific Calorie Goals
    func calculateMealGoals(for user: UserModel) -> [MealType: Int] {
        let totalCalories = user.calorieGoal

        let distribution: [MealType: Double] = [
            .breakfast: 0.25, // 25% of daily calories
            .lunch: 0.35,     // 35% of daily calories
            .dinner: 0.30,    // 30% of daily calories
            .snack: 0.10      // 10% of daily calories
        ]

        var mealGoals: [MealType: Int] = [:]
        for (meal, percentage) in distribution {
            mealGoals[meal] = Int(Double(totalCalories) * percentage)
        }

        return mealGoals
    }
}
