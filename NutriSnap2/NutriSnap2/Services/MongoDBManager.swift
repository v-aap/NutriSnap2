import Foundation

class MongoDBManager {
    static let shared = MongoDBManager()

    private let baseURL = "https://data.mongodb-api.com/app/67d07e18cbf53618b5f6f80b/endpoint/data/v1/action"
    private let apiKey = "58dc8397-3be1-49d3-8b2c-40bfa2434637"
    private let databaseName = "NutriSnapDB"
    private let usersCollection = "users"

    // MARK: - Register User
    func registerUser(user: UserModel, completion: @escaping (Bool) -> Void) {
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
                "firstName": user.firstName,
                "lastName": user.lastName,
                "email": user.email,
                "passwordHash": user.passwordHash, 
                "calorieGoal": user.calorieGoal ?? 2000
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: userData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            completion(error == nil)
        }.resume()
    }

    // MARK: - User Login
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(baseURL)/findOne")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apiKey")

        let hashedPassword = SecurityManager.shared.hashPassword(password) 

        let query: [String: Any] = [
            "dataSource": "Cluster0",
            "database": databaseName,
            "collection": usersCollection,
            "filter": ["email": email, "passwordHash": hashedPassword] 
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
}
