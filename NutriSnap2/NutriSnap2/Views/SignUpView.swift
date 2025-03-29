import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var navigateToRootContainer = false
    @State private var showSuccessAlert = false
    
    @State private var hasBlurredFirstName = false
    @State private var hasBlurredLastName = false
    @State private var hasBlurredEmail = false
    @State private var hasBlurredPassword = false
    @State private var hasBlurredConfirmPassword = false
    
    @State private var wasFocusedFirstName = false
    @State private var wasFocusedLastName = false
    @State private var wasFocusedEmail = false
    @State private var wasFocusedPassword = false
    @State private var wasFocusedConfirmPassword = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // MARK: - First Name Input
                TextField("First Name *", text: $viewModel.firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                    .padding(.horizontal)
                    .focused($focusedField, equals: .firstName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .lastName
                    }
                    .onChange(of: focusedField) { newField in
                        if newField == .firstName {
                            wasFocusedFirstName = true
                        } else if wasFocusedFirstName {
                            hasBlurredFirstName = true
                        }
                    }

                
                if let error = viewModel.firstNameMessage, hasBlurredFirstName {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -10)
                }

                // MARK: - Last Name Input
                TextField("Last Name *", text: $viewModel.lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                    .padding(.horizontal)
                    .focused($focusedField, equals: .lastName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
                    .onChange(of: focusedField) { newField in
                        if newField == .lastName {
                            wasFocusedLastName = true
                        } else if wasFocusedLastName {
                            hasBlurredLastName = true
                        }
                    }

                
                if let error = viewModel.lastNameMessage, hasBlurredLastName {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -10)
                }

                // MARK: - Email Input
                TextField("name@example.com *", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(.horizontal)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .onChange(of: focusedField) { newField in
                        if newField == .email {
                            wasFocusedEmail = true
                        } else if wasFocusedEmail {
                            hasBlurredEmail = true
                        }
                    }

                
                if let error = viewModel.emailMessage, hasBlurredEmail {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -10)
                }

                // MARK: - Password Input
                SecureField("Password *", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                    .onChange(of: focusedField) { newField in
                        if newField == .password {
                            wasFocusedPassword = true
                        } else if wasFocusedPassword {
                            hasBlurredPassword = true
                        }
                    }

                
                if let error = viewModel.passwordMessage, hasBlurredPassword {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -10)
                }

                // MARK: - Confirm Password Input
                SecureField("Confirm Password *", text: $viewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onChange(of: focusedField) { newField in
                        if newField == .confirmPassword {
                            wasFocusedConfirmPassword = true
                        } else if wasFocusedConfirmPassword {
                            hasBlurredConfirmPassword = true
                        }
                    }


                if let error = viewModel.confirmPasswordMessage, hasBlurredConfirmPassword {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -10)
                }
                
                // MARK: - Sign Up Button
                Button(action: {
                    viewModel.signUp { success in
                        if success {
                            showSuccessAlert = true
                        }
                    }
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isFormValid ? Color.green : Color.gray)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .disabled(!viewModel.isFormValid)

                Spacer()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(
                    title: Text("Sign Up Failed"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Account Created", isPresented: $showSuccessAlert) {
                Button("OK") {
                    navigateToRootContainer = true
                }
            } message: {
                Text("Your account has been successfully created. Tap OK to proceed to login.")
            }
            .navigationDestination(isPresented: $navigateToRootContainer) {
                RootContainerView()
            }
            .navigationBarHidden(true)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewDevice("iPhone 14 Plus")
    }
}
