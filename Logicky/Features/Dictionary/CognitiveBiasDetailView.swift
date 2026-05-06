import SwiftUI

struct CognitiveBiasDetailView: View {
    let biasId: String
    @Binding var navigationPath: NavigationPath

    private var bias: CognitiveBias? {
        CognitiveBiasService.shared.bias(for: biasId)
    }

    var body: some View {
        ScrollView {
            if let bias {
                VStack(alignment: .leading, spacing: 22) {
                    header(bias: bias)
                    CognitiveBiasDiagramView(bias: bias)
                    sectionCard(title: "解説", icon: "text.book.closed.fill") {
                        Text(bias.description)
                            .font(.body)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(6)
                    }
                    sectionCard(title: "ビジネスでの例", icon: "briefcase.fill") {
                        Text(bias.businessExample)
                            .font(.body)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(6)
                    }
                    sectionCard(title: "こんな場面で注意", icon: "exclamationmark.triangle.fill") {
                        Text(bias.dangerScene)
                            .font(.body)
                            .foregroundStyle(Color.appText)
                            .lineSpacing(6)
                    }
                    preventionCard(bias.prevention)
                    if !bias.relatedUnits.isEmpty {
                        relatedUnitsSection(bias.relatedUnits)
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(bias?.technicalName ?? "")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }

    private func header(bias: CognitiveBias) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(bias.displayName)
                .font(.title3.bold())
                .foregroundStyle(Color.appText)
            HStack(spacing: 4) {
                Text(bias.technicalName)
                    .font(.subheadline)
                    .foregroundStyle(Color.appGray)
                if let reading = bias.reading {
                    Text("（\(reading)）")
                        .font(.caption)
                        .foregroundStyle(Color.appGray)
                }
            }
            Text(bias.definition)
                .font(.subheadline)
                .foregroundStyle(Color.tiffany)
                .padding(.top, 2)
        }
        .padding(.top, 4)
    }

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

    private func preventionCard(_ prevention: String) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.tiffany)
                .frame(width: 3)
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 8) {
                Label("防ぐためのコツ", systemImage: "shield.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.tiffany)
                Text(prevention)
                    .font(.subheadline)
                    .foregroundStyle(Color.appText)
                    .lineSpacing(4)
            }
            .padding(.leading, 14)
            .padding(.vertical, 16)
            .padding(.trailing, 16)
            Spacer()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }

    private func relatedUnitsSection(_ unitIds: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("関連する思考法", systemImage: "link")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.tiffany)

            ForEach(unitIds, id: \.self) { unitId in
                if let method = ThinkingMethodService.shared.all.first(where: { $0.unitId == unitId }) {
                    Button {
                        navigationPath.append(AppRoute.dictionaryDetail(methodId: method.id))
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: method.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(Color.tiffany)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(method.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appText)
                                Text(method.tagline)
                                    .font(.caption)
                                    .foregroundStyle(Color.appSub)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.appGray)
                        }
                        .padding(12)
                        .background(Color.tiffany.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.tiffany.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cardBorder, lineWidth: 1))
    }
}
