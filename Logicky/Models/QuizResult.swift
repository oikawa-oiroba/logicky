import Foundation

/// クイズの結果モデル
struct QuizResult {
    let totalScore: Int
    /// 構造的思考スコア（0〜100）
    let structureScore: Int
    /// 論理性スコア（0〜100）
    let logicScore: Int
    /// 具体性スコア（0〜100）
    let specificityScore: Int
    let answers: [Answer]
}
