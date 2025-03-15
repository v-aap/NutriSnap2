import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private let realm: Realm

    private init() {
        do {
            realm = try Realm()
            print("✅ Realm Database initialized at: \(realm.configuration.fileURL!)")
        } catch {
            fatalError("❌ Failed to initialize Realm: \(error.localizedDescription)")
        }
    }

    // Save a meal to Realm
    func saveMeal(meal: MealEntry) {
        do {
            try realm.write {
                realm.add(meal)
            }
            print("✅ Meal saved: \(meal.foodName) - \(meal.calories) kcal")
        } catch {
            print("❌ Error saving meal: \(error.localizedDescription)")
        }
    }

    // Fetch all meals
    func fetchMeals() -> Results<MealEntry> {
        return realm.objects(MealEntry.self).sorted(byKeyPath: "date", ascending: false)
    }

    // Delete a meal
    func deleteMeal(meal: MealEntry) {
        do {
            try realm.write {
                realm.delete(meal)
            }
            print("✅ Meal deleted: \(meal.foodName)")
        } catch {
            print("❌ Error deleting meal: \(error.localizedDescription)")
        }
    }
}
