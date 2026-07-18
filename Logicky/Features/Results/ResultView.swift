import SwiftUI

struct ResultView: View {
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var viewModel: QuizViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleHeader

                if let result = viewModel.quizResult {
                    totalScoreSection(result)
                    radarSection(result)
                    feedbackSection(result)
                } else {
                    Text("結果を計算中...")
                        .foregroundStyle(Color.appSub)
                        .padding()
                }

                nextSessionButton
                retryWrongButton
                reviewButton
                homeButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.appBg)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $viewModel.newlyAcquiredBadge) { celebration in
            BadgeAcquisitionSheet(unit: celebration.unit, isAcquired: celebration.isAcquired) {
                viewModel.newlyAcquiredBadge = nil
            }
        }
    }

    // MARK: - Title

    private var titleHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.tiffany)
                .padding(.top, 28)
            Text("単元クリア！")
                .font(.title.bold())
                .foregroundStyle(Color.appText)
            Text("結果フィードバック")
                .font(.subheadline)
                .foregroundStyle(Color.appSub)
        }
    }

    // MARK: - Total Score

    private func totalScoreSection(_ result: QuizResult) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.cardBorder, lineWidth: 14)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: CGFloat(result.totalScore) / 100)
                    .stroke(Color.tiffany, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: result.totalScore)

                VStack(spacing: 2) {
                    Text("\(result.totalScore)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.tiffany)
                    Text("点")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSub)
                }
            }

            Text(rankLabel(result.totalScore))
                .font(.headline)
                .foregroundStyle(Color.tiffany)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Radar

    private func radarSection(_ result: QuizResult) -> some View {
        VStack(spacing: 12) {
            Text("3軸評価")
                .font(.headline)
                .foregroundStyle(Color.appText)
                .frame(maxWidth: .infinity, alignment: .leading)

            RadarChartView(
                values: [
                    Double(result.structureScore) / 100,
                    Double(result.logicScore) / 100,
                    Double(result.specificityScore) / 100
                ],
                labels: ["構造", "論理性", "具体性"]
            )
            .frame(height: 220)

            HStack(spacing: 12) {
                ScoreChip(title: "構造", score: result.structureScore)
                ScoreChip(title: "論理性", score: result.logicScore)
                ScoreChip(title: "具体性", score: result.specificityScore)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Per-Question Feedback

    private func feedbackSection(_ result: QuizResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("問題ごとのフィードバック")
                .font(.headline)
                .foregroundStyle(Color.appText)

            ForEach(Array(result.feedbacks.enumerated()), id: \.offset) { index, fb in
                questionFeedbackCard(index: index + 1, feedback: fb)
            }
        }
    }

    private func questionFeedbackCard(index: Int, feedback: QuestionFeedback) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Q\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.tiffany)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(feedback.question.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appText)
                    .lineLimit(2)

                Spacer()

                if feedback.answer.isSkipped {
                    Text("スキップ")
                        .font(.caption)
                        .foregroundStyle(Color.appGray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.appBg)
                        .clipShape(Capsule())
                } else {
                    Text("\(feedback.score)点")
                        .font(.subheadline.bold())
                        .foregroundStyle(feedback.score >= 70 ? Color.tiffany : Color.appGray)
                }
            }

            // 問題文（これがないと振り返れない）
            Text(feedback.question.body)
                .font(.subheadline)
                .foregroundStyle(Color.appText)
                .lineSpacing(4)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if feedback.question.type == .multipleChoice {
                mcFeedback(feedback)
            } else {
                ftFeedback(feedback)
            }

            QuestionFeedbackForm(
                questionId: feedback.question.id,
                unit: feedback.question.unit ?? "",
                selectedChoiceId: feedback.answer.selectedChoiceId
            )
            .id(feedback.question.id)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func mcFeedback(_ feedback: QuestionFeedback) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !feedback.answer.isSkipped, let correct = feedback.isCorrect {
                HStack {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title3)
                    Text(correct ? "正解！" : "不正解")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(correct ? Color.tiffany : Color.appGray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background((correct ? Color.tiffany : Color.appGray).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if let selectedId = feedback.answer.selectedChoiceId,
               let selected = feedback.question.choices?.first(where: { $0.id == selectedId }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなたの回答")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appSub)
                    Text(selected.text)
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                }
            }

            if let correctId = feedback.question.correctChoiceId,
               let correct = feedback.question.choices?.first(where: { $0.id == correctId }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("正解")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.tiffany)
                    Text(correct.text)
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                }
            }

            if let explanation = feedback.question.explanation {
                VStack(alignment: .leading, spacing: 6) {
                    Label("解説", systemImage: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.tiffany)
                    Text(explanation)
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                        .lineSpacing(4)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.tiffany.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func ftFeedback(_ feedback: QuestionFeedback) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !feedback.answer.freeText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("あなたの回答")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appSub)
                    Text(feedback.answer.freeText)
                        .font(.subheadline)
                        .foregroundStyle(Color.appText)
                        .lineSpacing(4)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appBg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if let detail = feedback.freeTextDetail {
                ftScoreDetail(detail)
            }

            if let rubric = feedback.question.rubricJson {
                VStack(alignment: .leading, spacing: 8) {
                    Label("採点観点", systemImage: "list.bullet.clipboard")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appSub)

                    RubricRow(axis: "構造", description: rubric.structure)
                    RubricRow(axis: "論理性", description: rubric.logic)
                    RubricRow(axis: "具体性", description: rubric.specificity)
                }
                .padding(12)
                .background(Color.appBg)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if feedback.question.sampleGoodAnswer != nil {
                SampleAnswerAccordion(question: feedback.question)
            }
        }
    }

    private func ftScoreDetail(_ detail: FreeTextScoreDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                ftScoreBar(label: "構造", score: detail.structureScore)
                ftScoreBar(label: "論理性", score: detail.logicScore)
                ftScoreBar(label: "具体性", score: detail.specificityScore)
            }

            if !detail.strengths.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(detail.strengths, id: \.self) { s in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.tiffany)
                            Text(s).font(.caption).foregroundStyle(Color.appText)
                        }
                    }
                }
            }

            if !detail.weaknesses.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(detail.weaknesses, id: \.self) { w in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "arrow.up.circle")
                                .font(.caption)
                                .foregroundStyle(Color.appGray)
                            Text(w).font(.caption).foregroundStyle(Color.appText)
                        }
                    }
                }
            }

            if !detail.advice.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(Color.tiffany)
                    Text(detail.advice)
                        .font(.caption)
                        .foregroundStyle(Color.appText)
                        .lineSpacing(3)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.tiffany.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color.appBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func ftScoreBar(label: String, score: Int) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.caption2).foregroundStyle(Color.appSub)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= score ? Color.tiffany : Color.cardBorder)
                        .frame(height: 8)
                }
            }
            Text("\(score)/5")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(score >= 4 ? Color.tiffany : Color.appGray)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Review Button

    private var reviewButton: some View {
        Button {
            navigationPath.append(AppRoute.review)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                Text("回答を振り返る")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundStyle(Color.tiffany)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.tiffany, lineWidth: 1)
            )
        }
    }

    // MARK: - Next Session（今日の5問→次の5問とどんどん進める）

    @ViewBuilder
    private var nextSessionButton: some View {
        if viewModel.mode == .training, let nextUnitId = viewModel.nextTrainingUnitId() {
            let sameUnit = nextUnitId == viewModel.unitId
            let unitName = UnitModel.all.first { $0.id == nextUnitId }?.displayName ?? ""
            Button {
                navigationPath.append(AppRoute.quiz(unitId: nextUnitId, mode: .training))
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text(sameUnit ? "次の5問に進む（\(unitName)）" : "次の単元へ（\(unitName)）")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.tiffany)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Retry Wrong Questions

    private var wrongQuestionIds: [String] {
        viewModel.quizResult?.feedbacks
            .filter { $0.question.type == .multipleChoice && $0.isCorrect == false }
            .map { $0.question.id } ?? []
    }

    @ViewBuilder
    private var retryWrongButton: some View {
        let ids = wrongQuestionIds
        if !ids.isEmpty {
            Button {
                let unitId = viewModel.unitId
                viewModel.prepareRetry(questionIds: ids)
                navigationPath.append(AppRoute.quiz(unitId: unitId, mode: .training))
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("間違えた\(ids.count)問にもう一度挑戦")
                        .fontWeight(.semibold)
                }
                .font(.headline)
                .foregroundStyle(Color.tiffany)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.tiffany.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Home Button

    private var homeButton: some View {
        Button {
            viewModel.reset()
            navigationPath = NavigationPath()
        } label: {
            HStack {
                Image(systemName: "house.fill")
                Text("ホームに戻る")
                    .fontWeight(.semibold)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.tiffany)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Helpers

    private func rankLabel(_ score: Int) -> String {
        switch score {
        case 80...100: return "優秀なロジカルシンカー"
        case 60..<80:  return "着実に成長中"
        case 40..<60:  return "まだ伸びしろあり"
        default:       return "基礎から積み上げよう"
        }
    }
}

// MARK: - Sub-components

private struct ScoreChip: View {
    let title: String
    let score: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption2.weight(.semibold)).foregroundStyle(Color.appSub)
            Text("\(score)").font(.title3.bold()).foregroundStyle(Color.tiffany)
            Text("点").font(.caption2).foregroundStyle(Color.appSub)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 1))
    }
}

private struct RubricRow: View {
    let axis: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(axis)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.tiffany)
                .frame(width: 40, alignment: .leading)
            Text(description)
                .font(.caption)
                .foregroundStyle(Color.appSub)
                .lineSpacing(3)
        }
    }
}

// MARK: - Badge Acquisition Sheet

struct BadgeAcquisitionSheet: View {
    let unit: UnitModel
    var isAcquired: Bool = true
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.tiffany.opacity(0.12))
                    .frame(width: 120, height: 120)
                Image(systemName: isAcquired ? "checkmark.seal.fill" : "rosette")
                    .font(.system(size: 54))
                    .foregroundStyle(Color.tiffany)
            }
            VStack(spacing: 8) {
                Text(isAcquired ? "バッジ獲得！" : "単元クリア！")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appText)
                Text("\(unit.displayName)")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                Text(isAcquired ? "全問正解を達成しました！" : "正答率80%以上を達成しました")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSub)
                    .padding(.top, 4)
            }
            .multilineTextAlignment(.center)
            Button {
                onDismiss()
            } label: {
                Text("続ける")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.tiffany)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            Spacer()
        }
        .background(Color.appBg)
        .presentationDetents([.medium])
    }
}

private struct SampleAnswerAccordion: View {
    let question: Question
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Color.tiffany)
                    Text("模範解答例を見る")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.tiffany)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.appGray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    if let answer = question.sampleGoodAnswer {
                        Text(answer)
                            .font(.caption)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(4)
                            .padding(.horizontal, 12)
                            .padding(.top, 8)
                    }
                    if let points = question.sampleGoodPoints, !points.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ポイント")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.tiffany)
                            ForEach(points, id: \.self) { point in
                                HStack(alignment: .top, spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 9))
                                        .foregroundStyle(Color.tiffany)
                                        .padding(.top, 1)
                                    Text(point)
                                        .font(.caption)
                                        .foregroundStyle(Color.appText)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    Text("※ AIによる自動採点です。参考程度にご活用ください。")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.appGray)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                }
            }
        }
        .background(Color.tiffany.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tiffany.opacity(0.2), lineWidth: 1))
    }
}
