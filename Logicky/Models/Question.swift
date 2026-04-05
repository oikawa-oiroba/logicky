import Foundation

/// 問題タイプ
enum QuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case freeText = "free_text"
}

/// 選択肢（4択問題用）
struct Choice: Codable, Identifiable {
    let id: String
    let text: String
}

/// 自由記述問題の3軸採点ルーブリック
struct RubricItem: Codable {
    /// 構造的思考の評価観点
    let structure: String
    /// 論理性の評価観点
    let logic: String
    /// 具体性の評価観点
    let specificity: String
}

/// 問題モデル
struct Question: Codable, Identifiable {
    let id: String
    let type: QuestionType
    let level: Int
    let title: String
    let body: String
    let choices: [Choice]?
    let correctChoiceId: String?
    let explanation: String?
    /// 問題に関連するタグ（例: ["MECE", "構造化"]）
    let tags: [String]?
    /// 主に鍛える能力軸（例: "構造化"）
    let abilityAxis: String?
    /// 自由記述問題の採点ルーブリック
    let rubricJson: RubricItem?
}
