import Foundation
import MongoSwift
import NIO

class MongoDBManager {
    static let shared = MongoDBManager()
    
    private var client: MongoClient?
    private var database: MongoDatabase?
    private var usersCollection: MongoCollection<BSONDocument>?

    init() {
        do {
            let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)  // Handle async queries
            self.client = try MongoClient(
                "mongodb+srv://admin:ValOscar2025@nutrisnapdb.0yc8f.mongodb.net/?retryWrites=true&w=majority&appName=NutriSnapDB",
                using: elg
            )
            self.database = client?.db("NutriSnapDB")
            self.usersCollection = database?.collection("users")
            print("✅ Connected to MongoDB successfully")
        } catch {
            print("❌ MongoDB Connection Error: \(error)")
        }
    }

    deinit {
        try? client?.syncClose()
    }

    // MARK: - Register User
    func registerUser(user: UserModel) async -> Bool {
        guard let usersCollection = usersCollection else {
            print("❌ Error: Users collection is nil")
            return false
        }

        let userDocument: BSONDocument = [
            "firstName": .string(user.firstName),
            "lastName": .string(user.lastName),
            "email": .string(user.email),
            "passwordHash": .string(user.passwordHash),
            "calorieGoal": .int32(Int32(user.calorieGoal ?? 2000))
        ]

        do {
            let result = try await usersCollection.insertOne(userDocument)
            return result != nil  // Insert success if result is not nil
        } catch {
            print("❌ Error inserting user: \(error)")
            return false
        }
    }

    // MARK: - User Login
    func loginUser(email: String, password: String) async -> UserModel? {
        guard let usersCollection = usersCollection else {
            print("❌ Error: Users collection is nil")
            return nil
        }

        let hashedPassword = SecurityManager.shared.hashPassword(password)
        let query: BSONDocument = [
            "email": .string(email),
            "passwordHash": .string(hashedPassword)
        ]

        do {
            if let document = try await usersCollection.findOne(query) {
                return UserModel(
                    id: document["_id"]?.objectIDValue?.hex ?? UUID().uuidString,
                    firstName: document["firstName"]?.stringValue ?? "",
                    lastName: document["lastName"]?.stringValue ?? "",
                    email: document["email"]?.stringValue ?? "",
                    password: "",  // Passwords are not stored locally
                    calorieGoal: document["calorieGoal"]?.int32Value.map { Int($0) }
                )
            } else {
                print("❌ No user found with that email/password")
                return nil
            }
        } catch {
            print("❌ Error finding user: \(error)")
            return nil
        }
    }

    // MARK: - List All Users (For Debugging)
    func listAllUsers() async {
        guard let usersCollection = usersCollection else {
            print("❌ Error: Users collection is nil")
            return
        }

        do {
            let cursor = try await usersCollection.find()
            for try await user in cursor {
                print("👤 User: \(user)")
            }
        } catch {
            print("❌ Error retrieving users: \(error)")
        }
    }
}
