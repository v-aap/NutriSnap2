import Foundation

class MongoDBManager {
    static let shared = MongoDBManager()

    private let baseURL = "https://data.mongodb-api.com/app/67d07e18cbf53618b5f6f80b/endpoint/data/v1/action"
    private let apiKey = "58dc8397-3be1-49d3-8b2c-40bfa2434637"
    private let databaseName = "NutriSnapDB"
    
    // MARK: - User Management
    private let usersCollection = "users"

    func registerUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseURL)/insertOne")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apiKey")

        let userData: [String: Any] = [
            "dataSource": "Cluster0",
            "database": databaseName,
            "collection": usersCollection,
            "document": [
                "email": email,
                "password": password // 🚨 Hash passwords in a real app
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: userData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            completion(error == nil)
        }.resume()
    }

    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseURL)/findOne")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apiKey")

        let query: [String: Any] = [
            "dataSource": "Cluster0",
            "database": databaseName,
            "collection": usersCollection,
            "filter": ["email": email, "password": password]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: query)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                completion(jsonResponse["document"] != nil)
            } else {
                completion(false)
            }
        }.resume()
    }

    // MARK: - Meals Collection
    private let mealsCollection = "meals"

    func saveMeal(meal: MealEntry, userEmail: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseURL)/insertOne")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apiKey")

        let mealData: [String: Any] = [
            "dataSource": "Cluster0",
            "database": databaseName,
            "collection": mealsCollection,
            "document": [
                "userEmail": userEmail,
                "foodName": meal.foodName,
                "date": ISO8601DateFormatter().string(from: meal.date),
                "calories": meal.calories,
                "carbs": meal.carbs,
                "protein": meal.protein,
                "fats": meal.fats,
                "mealType": meal.mealType
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: mealData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            completion(error == nil)
        }.resume()
    }

    func fetchMeals(userEmail: String, completion: @escaping ([MealEntry]?) -> Void) {
        let url = URL(string: "\(baseURL)/find")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apiKey")

        let query: [String: Any] = [
            "dataSource": "Cluster0",
            "database": databaseName,
            "collection": mealsCollection,
            "filter": ["userEmail": userEmail]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: query)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let documents = jsonResponse["documents"] as? [[String: Any]] {

                    let meals = documents.compactMap { doc -> MealEntry? in
                        guard let foodName = doc["foodName"] as? String,
                              let dateString = doc["date"] as? String,
                              let date = ISO8601DateFormatter().date(from: dateString),
                              let calories = doc["calories"] as? Int,
                              let carbs = doc["carbs"] as? Int,
                              let protein = doc["protein"] as? Int,
                              let fats = doc["fats"] as? Int,
                              let mealType = doc["mealType"] as? String
                        else { return nil }

                        return MealEntry(date: date, foodName: foodName, calories: calories, carbs: carbs, protein: protein, fats: fats, isManualEntry: true, mealType: mealType)
                    }
                    completion(meals)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
