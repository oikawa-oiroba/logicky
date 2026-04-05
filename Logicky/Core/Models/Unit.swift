import Foundation

struct UnitModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let levelId: Int
    let totalQuestions: Int

    static let all: [UnitModel] = [
        // Level 1 基礎
        UnitModel(id: "mece",        name: "MECE",      levelId: 1, totalQuestions: 3),
        UnitModel(id: "deduction",   name: "演繹法",     levelId: 1, totalQuestions: 3),
        UnitModel(id: "fact_opinion",name: "事実と意見", levelId: 1, totalQuestions: 3),
        // Level 2 応用
        UnitModel(id: "logic_tree",  name: "ロジックツリー", levelId: 2, totalQuestions: 3),
        UnitModel(id: "3c",          name: "3C分析",    levelId: 2, totalQuestions: 3),
        UnitModel(id: "5w2h",        name: "5W2H",      levelId: 2, totalQuestions: 3),
        // Level 3 実践
        UnitModel(id: "fermi",       name: "フェルミ推定",  levelId: 3, totalQuestions: 3),
        UnitModel(id: "causality",   name: "因果関係",   levelId: 3, totalQuestions: 3),
        UnitModel(id: "critical",    name: "批判的思考", levelId: 3, totalQuestions: 3),
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
