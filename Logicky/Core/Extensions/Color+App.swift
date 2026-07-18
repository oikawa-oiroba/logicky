import SwiftUI

extension Color {
    static let tiffany    = Color(red: 10/255,  green: 186/255, blue: 181/255)
    static let appBg      = Color(red: 248/255, green: 249/255, blue: 250/255)
    static let appText    = Color(red: 26/255,  green: 26/255,  blue: 26/255)
    static let appSub     = Color(red: 107/255, green: 114/255, blue: 128/255)
    static let cardBorder = Color(red: 229/255, green: 231/255, blue: 235/255)
    static let appGray    = Color(red: 156/255, green: 163/255, blue: 175/255)

    /// スコア帯ごとの色（低いほど赤 → 黄 → 青 → ターコイズ）
    static func scoreColor(_ score: Int) -> Color {
        switch score {
        case ..<40:  return Color(red: 231/255, green: 76/255,  blue: 60/255)   // 赤
        case ..<60:  return Color(red: 243/255, green: 183/255, blue: 32/255)   // 黄
        case ..<80:  return Color(red: 59/255,  green: 130/255, blue: 246/255)  // 青
        default:     return .tiffany
        }
    }

    /// スコアリング用のシェイプスタイル。満点はレインボー
    static func scoreRingStyle(_ score: Int) -> AnyShapeStyle {
        if score >= 100 {
            return AnyShapeStyle(AngularGradient(
                colors: [.red, .orange, .yellow, .green, .tiffany, .blue, .purple, .red],
                center: .center
            ))
        }
        return AnyShapeStyle(scoreColor(score))
    }
}
