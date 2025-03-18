import SwiftUI

/// Standard text input field
struct InputField: View {
    let title: String
    @Binding var text: String
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.horizontal)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 15)
            }
        }
    }
}

/// Secure password input field
struct SecureInputField: View {
    let title: String
    @Binding var text: String
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SecureField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.oneTimeCode)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.asciiCapable)
                .padding(.horizontal)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.leading, 15)
            }
        }
    }
}
