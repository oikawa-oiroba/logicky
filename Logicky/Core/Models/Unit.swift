import Foundation

struct UnitModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String         // technical name shown in dictionary / expert contexts
    let displayName: String  // friendly action-oriented name shown in quiz / learning UI
    let levelId: Int
    let totalQuestions: Int
    let description: String

    static let all: [UnitModel] = [
        // Level 1 基礎
        UnitModel(id: "mece",        name: "MECE",          displayName: "モレなく分ける力",      levelId: 1, totalQuestions: 3, description: "漏れなく・重複なく分類する技術"),
        UnitModel(id: "deduction",   name: "演繹法",         displayName: "筋道を立てる力",        levelId: 1, totalQuestions: 3, description: "前提から結論を論理的に導く推論法"),
        UnitModel(id: "fact_opinion",name: "事実と意見",     displayName: "事実を見抜く力",        levelId: 1, totalQuestions: 3, description: "客観的事実と主観的意見を見分ける力"),
        // Level 2 応用
        UnitModel(id: "logic_tree",  name: "ロジックツリー", displayName: "問題を分解する力",      levelId: 2, totalQuestions: 3, description: "問題を構造的に分解する手法"),
        UnitModel(id: "3c",          name: "3C分析",         displayName: "市場を読む力",          levelId: 2, totalQuestions: 3, description: "顧客・競合・自社で市場を読む分析法"),
        UnitModel(id: "5w2h",        name: "5W2H",           displayName: "具体的に伝える力",      levelId: 2, totalQuestions: 3, description: "具体的な行動計画を作るフレームワーク"),
        // Level 3 実践
        UnitModel(id: "fermi",       name: "フェルミ推定",   displayName: "ざっくり推定する力",    levelId: 3, totalQuestions: 3, description: "未知の数字を論理で推定する技術"),
        UnitModel(id: "causality",   name: "因果関係",       displayName: "原因と結果を見分ける力", levelId: 3, totalQuestions: 3, description: "相関と因果を見分ける思考法"),
        UnitModel(id: "critical",    name: "批判的思考",     displayName: "ツッコミを入れる力",    levelId: 3, totalQuestions: 3, description: "主張の弱点を見つける批判的思考"),
    ]
}

struct LevelModel: Identifiable {
    let id: Int
    let name: String
    let description: String

    var units: [UnitModel] { UnitModel.all.filter { $0.levelId == id } }

    static let all: [LevelModel] = [
        LevelModel(id: 1, name: "Level 1", description: "基礎"),
        LevelModel(id: 2, name: "Level 2", description: "応用"),
        LevelModel(id: 3, name: "Level 3", description: "実践"),
    ]
}
