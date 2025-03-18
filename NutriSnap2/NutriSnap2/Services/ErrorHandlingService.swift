//
//  ErrorHandlingService.swift
//  NutriSnap2
//
//  Created by Valeria Arce on 2025-03-18.
//

import FirebaseAuth
import FirebaseFirestore

class ErrorHandlingService {
    
    // MARK: - Convert Firebase Authentication Errors to User-Friendly Messages
    static func getAuthErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "An account already exists with this email."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email format."
        case AuthErrorCode.weakPassword.rawValue:
            return "Your password is too weak. Please use a stronger password."
        default:
            return error.localizedDescription
        }
    }

    // MARK: - Convert Firestore Errors to User-Friendly Messages
    static func getFirestoreErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case FirestoreErrorCode.permissionDenied.rawValue:
            return "You do not have permission to perform this action."
        case FirestoreErrorCode.unavailable.rawValue:
            return "Firestore is currently unavailable. Please try again later."
        case FirestoreErrorCode.notFound.rawValue:
            return "The requested data was not found."
        default:
            return error.localizedDescription
        }
    }

    // MARK: - Convert General System Errors
    static func getSystemErrorMessage(_ error: Error) -> String {
        return "An unexpected error occurred: \(error.localizedDescription)"
    }
}
