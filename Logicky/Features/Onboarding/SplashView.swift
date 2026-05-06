import SwiftUI

struct SplashView: View {
    @State private var opacity = 0.0
    @State private var scale = 0.88

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 72))
                    .foregroundStyle(Color.tiffany)

                Text("Logicky")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Color.appText)

                Text("思考力を、見える化する")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.appSub)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    opacity = 1.0
                    scale = 1.0
                }
            }
        }
    }
}
