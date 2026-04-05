import SwiftUI

struct SplashView: View {
    @State private var opacity = 0.0
    @State private var scale = 0.85

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.indigo, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

                Text("Logicky")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("思考力を、見える化する")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.85))
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
