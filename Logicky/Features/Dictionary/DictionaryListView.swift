import SwiftUI

struct DictionaryListView: View {
    @Binding var navigationPath: NavigationPath
    private let methods = ThinkingMethodService.shared.all

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(methods) { method in
                    Button {
                        navigationPath.append(AppRoute.dictionaryDetail(methodId: method.id))
                    } label: {
                        MethodListCard(method: method)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .navigationTitle("思考法辞典")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.appBg)
    }
}

// MARK: - Method Card

private struct MethodListCard: View {
    let method: ThinkingMethod

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.tiffany.opacity(0.1))
                    .frame(width: 46, height: 46)
                Image(systemName: method.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.tiffany)
            }

            VStack(alignment: .leading, spacing: 3) {
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
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }
}
