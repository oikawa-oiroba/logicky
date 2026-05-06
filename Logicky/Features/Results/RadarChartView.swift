import SwiftUI

struct RadarChartView: View {
    let values: [Double]
    let labels: [String]

    private let gridLevels = 5

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 * 0.7
            let count = values.count

            for level in 1...gridLevels {
                let ratio = Double(level) / Double(gridLevels)
                let path = polygonPath(center: center, radius: radius * ratio, sides: count)
                context.stroke(path, with: .color(Color.cardBorder), lineWidth: 1)
            }

            for i in 0..<count {
                let angle = axisAngle(index: i, total: count)
                let endpoint = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
                var path = Path()
                path.move(to: center)
                path.addLine(to: endpoint)
                context.stroke(path, with: .color(Color.cardBorder), lineWidth: 1)
            }

            var dataPath = Path()
            for (i, value) in values.enumerated() {
                let angle = axisAngle(index: i, total: count)
                let r = radius * max(0, min(1, value))
                let point = CGPoint(
                    x: center.x + cos(angle) * r,
                    y: center.y + sin(angle) * r
                )
                if i == 0 { dataPath.move(to: point) } else { dataPath.addLine(to: point) }
            }
            dataPath.closeSubpath()
            context.fill(dataPath, with: .color(Color.tiffany.opacity(0.2)))
            context.stroke(dataPath, with: .color(Color.tiffany), lineWidth: 2.5)

            for (i, value) in values.enumerated() {
                let angle = axisAngle(index: i, total: count)
                let r = radius * max(0, min(1, value))
                let point = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
                let dotRect = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
                context.fill(Path(ellipseIn: dotRect), with: .color(Color.tiffany))
            }
        }
        .overlay {
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 * 0.7
                let labelRadius = radius * 1.22

                ForEach(Array(labels.enumerated()), id: \.offset) { i, label in
                    let angle = axisAngle(index: i, total: labels.count)
                    let x = center.x + cos(angle) * labelRadius
                    let y = center.y + sin(angle) * labelRadius
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appText)
                        .position(x: x, y: y)
                }
            }
        }
    }

    private func axisAngle(index: Int, total: Int) -> Double {
        (Double(index) / Double(total)) * 2 * .pi - .pi / 2
    }

    private func polygonPath(center: CGPoint, radius: Double, sides: Int) -> Path {
        var path = Path()
        for i in 0..<sides {
            let angle = axisAngle(index: i, total: sides)
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
