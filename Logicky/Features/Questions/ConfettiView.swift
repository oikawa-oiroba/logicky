import SwiftUI

struct ConfettiView: View {
    /// 花吹雪の量・持続・色をカスタムできる（単元クリア時は豪華版を使う）
    var particleCount: Int = 35
    var maxLifetime: Double = 1.5
    var fadeDelay: Double = 0.3
    var palette: [Color]? = nil

    @State private var particles: [ConfettiParticle] = []
    @State private var opacity: Double = 1.0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let elapsed = now - particle.birthTime
                    guard elapsed < particle.lifetime else { continue }
                    let t = elapsed / particle.lifetime
                    let x = particle.origin.x + particle.velocity.x * elapsed
                    let y = particle.origin.y + particle.velocity.y * elapsed + 0.5 * 300 * elapsed * elapsed
                    let alpha = 1.0 - t
                    let scale = 1.0 - t * 0.3
                    let angle = Angle.radians(particle.rotation + particle.rotationSpeed * elapsed)

                    context.opacity = alpha
                    let transform = CGAffineTransform(translationX: x, y: y)
                        .rotated(by: angle.radians)
                        .scaledBy(x: scale, y: scale)

                    if particle.isCircle {
                        let rect = CGRect(x: -particle.size / 2, y: -particle.size / 2,
                                          width: particle.size, height: particle.size)
                        let path = Path(ellipseIn: rect)
                        context.fill(path.applying(transform), with: .color(particle.color))
                    } else {
                        let rect = CGRect(x: -particle.size / 2, y: -particle.size * 0.3,
                                          width: particle.size, height: particle.size * 0.6)
                        let path = Path(roundedRect: rect, cornerRadius: 2)
                        context.fill(path.applying(transform), with: .color(particle.color))
                    }
                }
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear {
            spawnParticles()
            withAnimation(.easeOut(duration: 1.2).delay(fadeDelay)) {
                opacity = 0
            }
        }
    }

    private func spawnParticles() {
        let colors: [Color] = palette ?? [Color.tiffany, Color.white, Color(red: 0.83, green: 0.69, blue: 0.22)]
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 200...450)
            return ConfettiParticle(
                origin: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY * 0.6),
                velocity: CGPoint(x: cos(angle) * speed, y: sin(angle) * speed - 200),
                color: colors.randomElement()!,
                size: Double.random(in: 6...12),
                rotation: Double.random(in: 0...(2 * .pi)),
                rotationSpeed: Double.random(in: -6...6),
                lifetime: Double.random(in: 0.8...maxLifetime),
                birthTime: now,
                isCircle: Bool.random()
            )
        }
    }
}

private struct ConfettiParticle {
    let origin: CGPoint
    let velocity: CGPoint
    let color: Color
    let size: Double
    let rotation: Double
    let rotationSpeed: Double
    let lifetime: Double
    let birthTime: Double
    let isCircle: Bool
}
