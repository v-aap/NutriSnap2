//
//  FirestoneService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    let db = Firestore.firestore()

    func saveUser(userID: String, data: [String: Any], completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userID).setData(data) { error in
            completion(error == nil)
        }
    }
}
