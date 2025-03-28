import SwiftUI
import FirebaseAuth

struct LogView: View {
    @State private var image: UIImage? = nil
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var navigateToMealEntry = false

    var body: some View {
        VStack {
            Spacer()

            // Meal Scan Button
            Button(action: {
                showImagePicker = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .shadow(radius: 8)
                    
                    VStack {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("Meal Scan")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()

            // Manual Entry Button
            Button(action: {
                navigateToMealEntry = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.blue]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .shadow(radius: 8)
                    
                    VStack {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        Text("Manual Entry")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image, sourceType: sourceType)
        }
        .fullScreenCover(isPresented: $navigateToMealEntry) {
            if let userID = Auth.auth().currentUser?.uid {
                MealEntryView(meal: MealEntry(
                    userID: userID,
                    date: Date(),
                    foodName: "",
                    calories: 0,
                    carbs: 0,
                    protein: 0,
                    fats: 0,
                    isManualEntry: true,
                    mealType: .breakfast
                ))
            } else {
                Text("Error: No user logged in")
            }
        }
    }
}

// MARK: - Preview
struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LogView()
                .navigationTitle("Log")
        }
    }
}
