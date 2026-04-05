import Foundation

/// ユーザーの回答モデル
struct Answer {
    let questionId: String
    let selectedChoiceId: String?  // 4択の場合
    let freeText: String?           // 自由記述の場合
    let isCorrect: Bool?            // 4択の場合のみ
}
