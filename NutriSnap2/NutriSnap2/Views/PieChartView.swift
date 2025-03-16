import SwiftUI

struct PieChartView: View {
    let carbs: Int
    let protein: Int
    let fats: Int
    let totalCalories: Int

    private var totalMacros: CGFloat {
        CGFloat(carbs + protein + fats)
    }

    private var carbsFraction: CGFloat {
        totalMacros == 0 ? 0 : CGFloat(carbs) / totalMacros
    }
    private var proteinFraction: CGFloat {
        totalMacros == 0 ? 0 : CGFloat(protein) / totalMacros
    }
    private var fatsFraction: CGFloat {
        totalMacros == 0 ? 0 : CGFloat(fats) / totalMacros
    }

    var body: some View {
        ZStack {
            // ✅ Carbs Slice
            PieSlice(startAngle: .degrees(0), endAngle: .degrees(360 * Double(carbsFraction)), color: .green)

            // ✅ Protein Slice
            PieSlice(startAngle: .degrees(360 * Double(carbsFraction)),
                     endAngle: .degrees(360 * Double(carbsFraction + proteinFraction)),
                     color: .blue)

            // ✅ Fats Slice
            PieSlice(startAngle: .degrees(360 * Double(carbsFraction + proteinFraction)),
                     endAngle: .degrees(360 * Double(carbsFraction + proteinFraction + fatsFraction)),
                     color: .red)

            // ✅ Center Total Calories
            VStack {
                Text("\(totalCalories)")
                    .font(.title)
                    .bold()
                Text("kcal")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 200, height: 200) // Adjust size as needed
    }
}

// ✅ Pie Slice Component
struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: width / 2, y: width / 2)
            Path { path in
                path.move(to: center)
                path.addArc(center: center,
                            radius: width / 2,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}
