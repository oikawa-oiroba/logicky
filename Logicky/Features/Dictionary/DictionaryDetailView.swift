import SwiftUI

struct DictionaryDetailView: View {
    let methodId: String
    @Binding var navigationPath: NavigationPath

    private var method: ThinkingMethod? {
        ThinkingMethodService.shared.all.first { $0.id == methodId }
    }

    var body: some View {
        ScrollView {
            if let method {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(method.displayName)
                            .font(.headline.bold())
                            .foregroundStyle(Color.tiffany)
                        Text(method.tagline)
                            .font(.subheadline)
                            .foregroundStyle(Color.appSub)
                    }
                    .padding(.top, 4)

                    ThinkingMethodDiagramView(method: method)

                    sectionCard(title: "解説", icon: "text.book.closed.fill") {
                        Text(method.explanation)
                            .font(.body)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(6)
                    }

                    sectionCard(title: "具体例", icon: "briefcase.fill") {
                        Text(method.example)
                            .font(.body)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(6)
                    }

                    sectionCard(title: "よくある間違い", icon: "exclamationmark.triangle.fill") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(method.commonMistakes.enumerated()), id: \.offset) { _, mistake in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.appGray)
                                        .padding(.top, 3)
                                    Text(mistake)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appText)
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }

                    if let unitId = method.unitId {
                        practiceButton(unitId: unitId)
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(method?.name ?? "")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.tiffany)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    // MARK: - Practice Button

    private func practiceButton(unitId: String) -> some View {
        Button {
            navigationPath.append(AppRoute.quiz(unitId: unitId, mode: .training))
        } label: {
            HStack {
                Image(systemName: "pencil.and.list.clipboard")
                Text("この思考法を練習する")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .font(.subheadline)
            .foregroundStyle(Color.tiffany)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.tiffany, lineWidth: 1)
            )
        }
    }
}
