import SwiftUI
import PhotosUI

struct EditPersonalInfoView: View {
    // MARK: - Bindings
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    
    // MARK: - State
    @State private var newFirstName: String
    @State private var newLastName: String
    @State private var newEmail: String
    @State private var profileImage: UIImage? // Holds selected image
    @State private var showImagePicker: Bool = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showUnsavedChangesAlert: Bool = false
    @State private var showSaveConfirmation: Bool = false
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Init
    init(firstName: Binding<String>, lastName: Binding<String>, email: Binding<String>) {
        self._firstName = firstName
        self._lastName = lastName
        self._email = email
        
        _newFirstName = State(initialValue: firstName.wrappedValue)
        _newLastName = State(initialValue: lastName.wrappedValue)
        _newEmail = State(initialValue: email.wrappedValue)
    }

    var body: some View {
        Form {
            // MARK: - Profile Picture Selection
            Section {
                VStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        showImagePickerActionSheet()
                    }) {
                        Text("Change Profile Picture")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // MARK: - First Name
            Section(header: Text("First Name")) {
                TextField("Enter new first name", text: $newFirstName)
                    .autocapitalization(.words)
            }

            // MARK: - Last Name
            Section(header: Text("Last Name")) {
                TextField("Enter new last name", text: $newLastName)
                    .autocapitalization(.words)
            }

            // MARK: - Email
            Section(header: Text("Email")) {
                TextField("Enter new email", text: $newEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }

            // MARK: - Change Password Button
            Section {
                NavigationLink(destination: ChangePasswordView()) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.orange)
                        Text("Change Password")
                    }
                }
            }
            
            // MARK: - Save Button (Green)
            Button(action: saveChanges) {
                Text("Save Changes")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Edit Personal Info")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showUnsavedChangesAlert) {
            Alert(
                title: Text("Unsaved Changes"),
                message: Text("You have unsaved changes. Are you sure you want to leave?"),
                primaryButton: .destructive(Text("Discard Changes")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showSaveConfirmation) {
            Alert(
                title: Text("Changes Saved"),
                message: Text("Your personal information has been updated successfully."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage, sourceType: imagePickerSource)
        }
    }

    // MARK: - Handle Dismiss with Unsaved Changes Check
    private func handleDismiss() {
        if newFirstName != firstName || newLastName != lastName || newEmail != email || profileImage != nil {
            showUnsavedChangesAlert = true
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }

    // MARK: - Show Image Picker Action Sheet
    private func showImagePickerActionSheet() {
        let alert = UIAlertController(title: "Select Profile Picture", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            imagePickerSource = .camera
            showImagePicker = true
        })
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            imagePickerSource = .photoLibrary
            showImagePicker = true
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    // MARK: - Save Changes
    private func saveChanges() {
        firstName = newFirstName
        lastName = newLastName
        email = newEmail
        showSaveConfirmation = true
    }
}

// MARK: - Preview
struct EditPersonalInfoView_Previews: PreviewProvider {
    @State static var firstName = "John"
    @State static var lastName = "Doe"
    @State static var email = "johndoe@email.com"
    
    static var previews: some View {
        NavigationView {
            EditPersonalInfoView(firstName: $firstName, lastName: $lastName, email: $email)
        }
    }
}
