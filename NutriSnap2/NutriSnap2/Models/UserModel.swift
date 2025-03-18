import RealmSwift

class UserModel: Object, Identifiable, Codable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var firstName: String
    @Persisted var lastName: String
    @Persisted var email: String
    @Persisted var dailyCalorieGoal: Int?

    convenience init(firstName: String, lastName: String, email: String, dailyCalorieGoal: Int?) {
        self.init()
        self._id = ObjectId.generate()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dailyCalorieGoal = dailyCalorieGoal
    }

    // MARK: - Codable Conformance
    enum CodingKeys: String, CodingKey {
        case _id
        case firstName
        case lastName
        case email
        case dailyCalorieGoal
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(ObjectId.self, forKey: ._id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decode(String.self, forKey: .email)
        self.dailyCalorieGoal = try container.decodeIfPresent(Int.self, forKey: .dailyCalorieGoal)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(dailyCalorieGoal, forKey: .dailyCalorieGoal)
    }
}
