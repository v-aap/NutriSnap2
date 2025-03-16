import Foundation
import RealmSwift

class UserModel: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var firstName: String
    @Persisted var lastName: String
    @Persisted var email: String
    @Persisted var dailyCalorieGoal: Int?

    convenience init(firstName: String, lastName: String, email: String, dailyCalorieGoal: Int?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dailyCalorieGoal = dailyCalorieGoal
    }
}
