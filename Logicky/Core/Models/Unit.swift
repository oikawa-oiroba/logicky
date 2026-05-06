import Foundation

struct UnitModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let levelId: Int         // 0 = basic, 1/2/3 = practical levels
    let totalQuestions: Int
    let description: String
    var reading: String?

    var isBasic: Bool { levelId == 0 }

    static let all: [UnitModel] = basic + practical

    // MARK: - Basic Units (levelId: 0)
    static let basic: [UnitModel] = [
        UnitModel(id: "grouping",    name: "分類・グルーピング",      displayName: "仲間分けする力",            levelId: 0, totalQuestions: 3, description: "共通点を見つけてグループに整理する考え方",     reading: nil),
        UnitModel(id: "why_deep",    name: "なぜなぜ分析",           displayName: "原因を深掘りする力",         levelId: 0, totalQuestions: 3, description: "「なぜ？」を繰り返して根本原因にたどり着く方法", reading: nil),
        UnitModel(id: "syllogism",   name: "三段論法",               displayName: "筋道を組み立てる力",         levelId: 0, totalQuestions: 3, description: "2つの前提から1つの結論を導く論理の基本形",     reading: "さんだんろんぽう"),
        UnitModel(id: "induction",   name: "帰納法",                 displayName: "共通点から法則を見つける力", levelId: 0, totalQuestions: 3, description: "複数の事実から共通するパターンを導き出す方法", reading: "きのうほう"),
        UnitModel(id: "analogy",     name: "アナロジー思考",          displayName: "似ている例から考える力",     levelId: 0, totalQuestions: 3, description: "ある分野の成功パターンを別の分野に応用する考え方", reading: nil),
        UnitModel(id: "comparison",  name: "対比・比較",              displayName: "違いを見つける力",           levelId: 0, totalQuestions: 3, description: "2つ以上のものを並べて共通点と相違点を明確にする方法", reading: "たいひ・ひかく"),
        UnitModel(id: "abstraction", name: "抽象化と具体化",          displayName: "抽象と具体を行き来する力",   levelId: 0, totalQuestions: 3, description: "具体的な事例から本質を抜き出したり具体例に落とす力", reading: "ちゅうしょうか・ぐたいか"),
        UnitModel(id: "hypothesis",  name: "仮説思考",               displayName: "まず予想してみる力",         levelId: 0, totalQuestions: 3, description: "情報不足でも仮の答えを立てて検証するアプローチ",  reading: "かせつしこう"),
        UnitModel(id: "whole_part",  name: "ズームイン・ズームアウト", displayName: "全体と部分を切り替える力",   levelId: 0, totalQuestions: 3, description: "全体像を俯瞰したり細部に注目したり視点を切り替える力", reading: nil),
        UnitModel(id: "sequencing",  name: "順序立て・プロセス思考",  displayName: "ステップで考える力",         levelId: 0, totalQuestions: 3, description: "物事を正しい順番に並べ手順として整理する力",     reading: nil),
        UnitModel(id: "fact_opinion",name: "事実と意見",              displayName: "事実を見抜く力",             levelId: 0, totalQuestions: 3, description: "客観的事実と主観的意見を見分ける力",           reading: nil),
        UnitModel(id: "pyramid",     name: "ピラミッド原則",          displayName: "結論から伝える力",           levelId: 0, totalQuestions: 3, description: "結論を先に述べ理由をピラミッド状に並べる技術",  reading: "ピラミッドげんそく"),
        UnitModel(id: "so_what",     name: "So What?",               displayName: "だから何？を導く力",         levelId: 0, totalQuestions: 3, description: "事実から論理的な示唆を導く技術",             reading: "ソーワット"),
        UnitModel(id: "5w2h",        name: "5W2H",                   displayName: "具体的に伝える力",           levelId: 0, totalQuestions: 3, description: "具体的な行動計画を作るフレームワーク",         reading: "ゴダブリューニエイチ"),
    ]

    // MARK: - Practical Units (levelId: 1/2/3)
    static let practical: [UnitModel] = [
        // Level 1 整理する力
        UnitModel(id: "mece",         name: "MECE",           displayName: "モレなく分ける力",       levelId: 1, totalQuestions: 3, description: "漏れなく・重複なく分類する技術",                reading: "ミーシー"),
        UnitModel(id: "logic_tree",   name: "ロジックツリー",  displayName: "問題を分解する力",       levelId: 1, totalQuestions: 3, description: "問題を構造的に分解する手法",                    reading: nil),
        UnitModel(id: "matrix",       name: "マトリックス分析",displayName: "優先順位をつける力",     levelId: 1, totalQuestions: 3, description: "2軸で選択肢を分類し優先順位を決める手法",        reading: nil),
        // Level 2 分析する力
        UnitModel(id: "3c",           name: "3C分析",          displayName: "市場を読む力",           levelId: 2, totalQuestions: 3, description: "顧客・競合・自社で市場を読む分析法",            reading: "スリーシーぶんせき"),
        UnitModel(id: "4p",           name: "4P分析",          displayName: "売り方を設計する力",     levelId: 2, totalQuestions: 3, description: "製品・価格・流通・販促の4軸で戦略を組む",        reading: "フォーピーぶんせき"),
        UnitModel(id: "profit_tree",  name: "利益ツリー",      displayName: "利益の構造を読む力",     levelId: 2, totalQuestions: 3, description: "利益の構造を分解して原因を特定する手法",          reading: "りえきツリー"),
        // Level 3 検証する力
        UnitModel(id: "fermi",        name: "フェルミ推定",    displayName: "ざっくり推定する力",     levelId: 3, totalQuestions: 3, description: "未知の数字を論理で推定する技術",                reading: nil),
        UnitModel(id: "causation",    name: "因果関係",        displayName: "原因と結果を見分ける力", levelId: 3, totalQuestions: 3, description: "相関と因果を見分ける思考法",                    reading: "いんがかんけい"),
        UnitModel(id: "critical",     name: "批判的思考",      displayName: "ツッコミを入れる力",     levelId: 3, totalQuestions: 3, description: "主張の弱点を見つける批判的思考",                reading: "ひはんてきしこう"),
        UnitModel(id: "sanity_check", name: "サニティチェック",displayName: "数字の妥当性を確かめる力", levelId: 3, totalQuestions: 3, description: "推計値の桁感を既知の数字で検証する技術",       reading: nil),
    ]
}

struct LevelModel: Identifiable {
    let id: Int
    let name: String
    let description: String

    var units: [UnitModel] { UnitModel.all.filter { $0.levelId == id } }

    static let basic = LevelModel(id: 0, name: "基礎編", description: "思考の道具箱")
    static let practical: [LevelModel] = [
        LevelModel(id: 1, name: "整理する力", description: "Level 1"),
        LevelModel(id: 2, name: "分析する力", description: "Level 2"),
        LevelModel(id: 3, name: "検証する力", description: "Level 3"),
    ]
    static let all: [LevelModel] = [basic] + practical
}
