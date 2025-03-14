import SwiftUI

struct FilterButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(15)
        }
    }
}

// MARK: - Preview
struct FilterButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            FilterButton(title: "All", isSelected: true) {}
            FilterButton(title: "Breakfast", isSelected: false) {}
            FilterButton(title: "Lunch", isSelected: false) {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
