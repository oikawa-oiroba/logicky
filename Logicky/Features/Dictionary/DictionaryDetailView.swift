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
                    Text(method.tagline)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)

                    sectionCard(title: "解説", icon: "text.book.closed.fill", color: .indigo) {
                        Text(method.explanation)
                            .font(.body)
                            .lineSpacing(6)
                    }

                    sectionCard(title: "具体例", icon: "briefcase.fill", color: .teal) {
                        Text(method.example)
                            .font(.body)
                            .lineSpacing(6)
                    }

                    sectionCard(title: "よくある間違い", icon: "exclamationmark.triangle.fill", color: .orange) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(method.commonMistakes.enumerated()), id: \.offset) { _, mistake in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                        .padding(.top, 3)
                                    Text(mistake)
                                        .font(.subheadline)
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
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Section Card

    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            .foregroundStyle(.indigo)
            .padding(16)
            .background(Color.indigo.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
