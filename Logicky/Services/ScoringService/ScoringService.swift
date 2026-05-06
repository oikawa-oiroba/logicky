import Foundation

final class ScoringService {
    static let shared = ScoringService()
    private init() {}

    func score(answer: SessionAnswer, question: Question) -> Int {
        guard !answer.isSkipped else { return 0 }
        switch question.type {
        case .multipleChoice:
            guard let selected = answer.selectedChoiceId,
                  let correct = question.correctChoiceId else { return 0 }
            return selected == correct ? 100 : 0
        case .freeText:
            let text = answer.freeText.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { return 0 }
            return scoreRuleBased(text: text).normalizedScore
        }
    }

    func buildResult(
        unitId: String,
        questions: [Question],
        sessionAnswers: [SessionAnswer]
    ) -> QuizResult {
        let feedbacks: [QuestionFeedback] = zip(questions, sessionAnswers).map { question, answer in
            let s = score(answer: answer, question: question)
            let correct: Bool? = question.type == .multipleChoice
                ? (!answer.isSkipped ? answer.selectedChoiceId == question.correctChoiceId : nil)
                : nil
            let detail: FreeTextScoreDetail? = question.type == .freeText && !answer.isSkipped
                ? scoreRuleBased(text: answer.freeText)
                : nil
            return QuestionFeedback(question: question, answer: answer, isCorrect: correct, score: s, freeTextDetail: detail)
        }

        let scores = feedbacks.map { $0.score }
        let total = scores.isEmpty ? 0 : scores.reduce(0, +) / scores.count

        let structureScore = axisScore(feedbacks: feedbacks, axis: "構造化", fallback: total)
        let logicScore     = axisScore(feedbacks: feedbacks, axis: "因果理解", fallback: total)
        let specificityScore = axisScore(feedbacks: feedbacks, axis: "具体性", fallback: total)

        return QuizResult(
            unitId: unitId,
            totalScore: total,
            structureScore: structureScore,
            logicScore: logicScore,
            specificityScore: specificityScore,
            feedbacks: feedbacks
        )
    }

    // MARK: - Rule-Based Free Text Scoring

    func scoreRuleBased(text: String) -> FreeTextScoreDetail {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Edge case: too short
        if trimmed.count < 20 {
            return FreeTextScoreDetail(
                structureScore: 1, logicScore: 1, specificityScore: 1, normalizedScore: 7,
                strengths: [], weaknesses: ["もう少し詳しく書いてみましょう"],
                advice: "回答を100字以上で記述すると、より的確な評価ができます"
            )
        }

        let structure  = calcStructure(trimmed)
        let logic      = calcLogic(trimmed)
        let specificity = calcSpecificity(trimmed)

        let raw = structure + logic + specificity
        let normalized = max(0, min(100, Int(Double(raw) / 15.0 * 100)))

        let strengths  = buildStrengths(s: structure, l: logic, sp: specificity)
        let weaknesses = buildWeaknesses(s: structure, l: logic, sp: specificity)
        let advice     = buildAdvice(s: structure, l: logic, sp: specificity)

        return FreeTextScoreDetail(
            structureScore: structure,
            logicScore: logic,
            specificityScore: specificity,
            normalizedScore: normalized,
            strengths: strengths,
            weaknesses: weaknesses,
            advice: advice
        )
    }

    // MARK: - Structure (1-5)

    private func calcStructure(_ text: String) -> Int {
        var score = 1

        // 改行2つ以上
        let newlineCount = text.components(separatedBy: "\n").count - 1
        if newlineCount >= 2 { score += 1 }

        // 接続詞
        let connectives = ["まず", "次に", "最後に", "第一に", "第二に", "一方", "また", "さらに", "そして", "①", "②", "③"]
        let connCount = connectives.filter { text.contains($0) }.count
        if connCount >= 2 { score += 1 }

        // ナンバリング
        let hasNumbering = text.contains("①") || text.contains("②") ||
                           text.range(of: #"[1-9]\."#, options: .regularExpression) != nil ||
                           text.contains("1.")
        if hasNumbering { score += 1 }

        // 文の数（句点区切り）
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: "。！？")).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if sentences.count >= 3 { score += 1 }

        return min(5, score)
    }

    // MARK: - Logic (1-5)

    private func calcLogic(_ text: String) -> Int {
        var score = 1

        // 因果表現
        let causalKeywords = ["なぜなら", "したがって", "そのため", "つまり", "よって", "だから", "理由は", "ゆえに", "から", "ので", "結果として"]
        let causalCount = causalKeywords.filter { text.contains($0) }.count
        if causalCount >= 3 { score += 2 }
        else if causalCount >= 1 { score += 1 }

        // 対比表現
        let contrastKeywords = ["一方", "しかし", "ただし", "反面", "一方で", "対して", "逆に", "しかしながら"]
        if contrastKeywords.contains(where: { text.contains($0) }) { score += 1 }

        // 仮説表現
        let hypotheticalKeywords = ["仮に", "もし", "とすると", "であれば", "と仮定", "想定すると"]
        if hypotheticalKeywords.contains(where: { text.contains($0) }) { score += 1 }

        return min(5, score)
    }

    // MARK: - Specificity (1-5)

    private func calcSpecificity(_ text: String) -> Int {
        var score = 1

        // 数字の含有
        let digitMatches = text.matches(of: /\d+/)
        if digitMatches.count >= 3 { score += 2 }
        else if digitMatches.count >= 1 { score += 1 }

        // 例示表現
        let exampleKeywords = ["例えば", "具体的に", "たとえば", "例として", "具体例", "事例", "例："]
        if exampleKeywords.contains(where: { text.contains($0) }) { score += 1 }

        // カタカナ3文字以上（固有名詞らしき単語）
        if text.range(of: "[ァ-ヴ]{3,}", options: .regularExpression) != nil { score += 1 }

        // 文字数による加点
        if text.count >= 200 { score += 1 }

        return min(5, score)
    }

    // MARK: - Feedback Generation

    private func buildStrengths(s: Int, l: Int, sp: Int) -> [String] {
        var result: [String] = []
        if s >= 4 { result.append("論点が整理されており、読みやすい構成です") }
        else if s >= 3 { result.append("文章の構成が意識されています") }
        if l >= 4 { result.append("因果関係が明確で、説得力のある論理展開です") }
        else if l >= 3 { result.append("根拠を示そうとする姿勢が見られます") }
        if sp >= 4 { result.append("具体的な数値や例があり、実務的な視点が感じられます") }
        else if sp >= 3 { result.append("具体例を交えて説明できています") }
        return result
    }

    private func buildWeaknesses(s: Int, l: Int, sp: Int) -> [String] {
        var result: [String] = []
        if s <= 2 { result.append("論点を箇条書きや番号で整理すると、より伝わりやすくなります") }
        if l <= 2 { result.append("「なぜなら」「したがって」を使って、理由と結論のつながりを明確にしましょう") }
        if sp <= 2 { result.append("「例えば〜」や具体的な数字を加えると、説得力が増します") }
        return result
    }

    private func buildAdvice(s: Int, l: Int, sp: Int) -> String {
        let minScore = min(s, l, sp)
        if s == minScore {
            return "まず結論を書き、その後に理由を2〜3点挙げる構成を試してみてください"
        } else if l == minScore {
            return "主張と根拠を「〜だから〜である」の形でつなげることを意識してみてください"
        } else {
            return "抽象的な表現を1つ選び、具体的な数字や事例に置き換えてみてください"
        }
    }

    // MARK: - Axis Score Helper

    private func axisScore(feedbacks: [QuestionFeedback], axis: String, fallback: Int) -> Int {
        let matching = feedbacks.filter { $0.question.abilityAxis == axis }
        guard !matching.isEmpty else { return fallback }
        return matching.map { $0.score }.reduce(0, +) / matching.count
    }
}
