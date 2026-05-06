import SwiftUI

struct CognitiveBiasListView: View {
    @Binding var navigationPath: NavigationPath
    private let service = CognitiveBiasService.shared

    private let categories: [(id: String, label: String, icon: String)] = [
        ("judgment", "判断の罠", "brain.head.profile"),
        ("reasoning", "推論の罠", "arrow.triangle.branch"),
        ("numbers", "数字の罠", "number.circle"),
        ("social", "対人の罠", "person.2"),
        ("decision", "意思決定の罠", "arrow.left.arrow.right")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(categories, id: \.id) { cat in
                    let biases = service.biases(for: cat.id)
                    if !biases.isEmpty {
                        categorySection(category: cat, biases: biases)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .navigationTitle("認知バイアス辞典")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }

    private func categorySection(
        category: (id: String, label: String, icon: String),
        biases: [CognitiveBias]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tiffany)
                Text(category.label)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appText)
            }

            ForEach(biases) { bias in
                Button {
                    navigationPath.append(AppRoute.cognitiveBiasDetail(biasId: bias.id))
                } label: {
                    BiasListCard(bias: bias)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct BiasListCard: View {
    let bias: CognitiveBias

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(bias.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appText)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 4) {
                    Text(bias.technicalName)
                        .font(.caption)
                        .foregroundStyle(Color.appGray)
                    if let reading = bias.reading {
                        Text("（\(reading)）")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.appGray)
                    }
                }
                Text(bias.definition)
                    .font(.caption)
                    .foregroundStyle(Color.appSub)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.appGray)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }
}
