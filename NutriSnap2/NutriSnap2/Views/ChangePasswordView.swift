import SwiftUI

struct ChangePasswordView: View {
    // MARK: - State
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPasswordMismatchAlert: Bool = false
    @State private var showPasswordChangeSuccess: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Current Password
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: - New Password
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // MARK: - Confirm Password
                Section(header: Text("Confirm Password")) {
                    SecureField("Re-enter new password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // MARK: - Save Button (Green)
                Button(action: changePassword) {
                    Text("Update Password")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .bold))
                }
            )
            .alert(isPresented: $showPasswordMismatchAlert) {
                Alert(
                    title: Text("Password Mismatch"),
                    message: Text("The new passwords do not match. Please try again."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showPasswordChangeSuccess) {
                Alert(
                    title: Text("Password Updated"),
                    message: Text("Your password has been changed successfully."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }

    // MARK: - Change Password Logic
    private func changePassword() {
        if newPassword.isEmpty || confirmPassword.isEmpty || currentPassword.isEmpty {
            return
        }
        
        if newPassword != confirmPassword {
            showPasswordMismatchAlert = true
        } else {
            showPasswordChangeSuccess = true
        }
    }
}

// MARK: - Preview
struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChangePasswordView()
        }
    }
}
