import SwiftUI
import FamilyControls

/// Onboarding step 13 (canvas V2-13): portion dial. The arc draws on appear; drag the ring, snaps to 5 min (15–120).
struct PortionStep: View {
    @ObservedObject var data: OnboardingData
    @Environment(\.kitchenTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(DietManager.self) private var dietManager
    @State private var drawn = false

    private let dial: CGFloat = 240
    private let radius: CGFloat = 100
    private let maxMinutes = 120, minMinutes = 15

    private var minutes: Int { data.dailyCarbLimitMinutes }
    private var fraction: Double { min(1, max(0, Double(minutes) / Double(maxMinutes))) }

    private var appCount: Int {
        let n = dietManager.foodGroupSelections[.carbs].map { $0.applicationTokens.count + $0.categoryTokens.count + $0.webDomainTokens.count } ?? 0
        #if targetEnvironment(simulator)
        return n == 0 ? 5 : n
        #else
        return n
        #endif
    }

    var body: some View {
        let carbs = theme.color(for: .carbs)
        OnboardingPage {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your daily Carbs portion").kitchenEyebrow().foregroundStyle(carbs).rise(1)
                OnboardingTitle(first: "How much feels", second: "like enough?", emphasis: false).rise(2)
            }
            dialCard.rise(3).padding(.top, 4)
            HStack(spacing: 8) {
                ForEach([30, 45, 60, 90], id: \.self) { p in
                    let on = p == minutes
                    Button { withAnimation(.easeOut(duration: 0.25)) { data.dailyCarbLimitMinutes = p } } label: {
                        Text("\(p) min").font(KitchenFont.label(13)).fontWeight(.bold)
                            .foregroundStyle(on ? theme.buttonText : theme.text)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(on ? theme.buttonBg : theme.surface, in: Capsule())
                            .overlay(Capsule().stroke(on ? .clear : theme.line, lineWidth: 1))
                    }
                    .buttonStyle(TactileButtonStyle())
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }.rise(4)
            HStack(spacing: 10) {
                Image(systemName: "circle.circle").font(.system(size: 17, weight: .medium)).foregroundStyle(carbs)
                (Text(appCount > 0 ? "One plate, shared by \(appCount) \(appCount == 1 ? "app" : "apps")." : "One plate, shared by your Carbs apps.").fontWeight(.bold)
                 + Text(" Fats and Protein never count."))
                    .font(KitchenFont.body(13)).foregroundStyle(theme.text).fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(theme.soft(.carbs, opacity: 0.10), in: RoundedRectangle(cornerRadius: 18))
            .rise(4)
        } footer: {
            KitchenPrimaryButton(title: "Set my portion", systemImage: "arrow.right") { data.nextScreen() }
                .editorialEntrance(delay: 0.9)
        }
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .timingCurve(0.2, 0.8, 0.2, 1, duration: 1.2).delay(0.4)) { drawn = true }
        }
        .sensoryFeedback(.increase, trigger: minutes) { old, new in new > old }
        .sensoryFeedback(.decrease, trigger: minutes) { old, new in new < old }
    }

    private var dialCard: some View {
        let carbs = theme.color(for: .carbs)
        return ZStack {
            ZStack {
                Circle().stroke(theme.surface2, lineWidth: 18).frame(width: radius * 2, height: radius * 2)
                Circle().stroke(theme.line2, style: StrokeStyle(lineWidth: 3, dash: [1.5, 50.86]))
                    .frame(width: radius * 2, height: radius * 2).rotationEffect(.degrees(-90))
                Circle().trim(from: 0, to: drawn ? fraction : 0)
                    .stroke(carbs, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .frame(width: radius * 2, height: radius * 2).rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.25), value: fraction)
                let ang = fraction * 2 * .pi
                Circle().fill(Color(hex: "FFFDF8")).overlay(Circle().stroke(carbs, lineWidth: 4)).frame(width: 30, height: 30)
                    .shadow(color: Color(hex: "3C2814").opacity(0.25), radius: 5, y: 4)
                    .offset(x: radius * sin(ang), y: -radius * cos(ang))
                    .opacity(drawn ? 1 : 0)
                    .animation(.easeOut(duration: 0.25), value: fraction)
                VStack(spacing: 4) {
                    Text("\(minutes)").font(KitchenFont.bigNumber(68)).tracking(-3).foregroundStyle(theme.text)
                        .contentTransition(.numericText()).animation(.snappy(duration: 0.2), value: minutes)
                    Text("MIN A DAY").font(.custom(KitchenFont.manrope, size: 12, relativeTo: .caption).weight(.bold))
                        .tracking(1.4).foregroundStyle(theme.muted)
                }
                .allowsHitTesting(false)
            }
            .frame(width: dial, height: dial)
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { setMinutes(from: $0.location) })
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Daily Carbs portion")
            .accessibilityValue("\(minutes) minutes")
            .accessibilityAdjustableAction { dir in
                switch dir {
                case .increment: data.dailyCarbLimitMinutes = min(maxMinutes, (minutes / 5) * 5 + 5)
                case .decrement: data.dailyCarbLimitMinutes = max(minMinutes, (minutes + 4) / 5 * 5 - 5)
                @unknown default: break
                }
            }
            Text("Drag the ring").font(KitchenFont.label(11)).foregroundStyle(theme.faint)
                .frame(maxHeight: .infinity, alignment: .bottom).padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity).frame(height: 300)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 32))
        .overlay(RoundedRectangle(cornerRadius: 32).stroke(theme.line, lineWidth: 1))
        .shadow(color: Color(hex: "5A401E").opacity(0.16), radius: 20, y: 18)
    }

    private func setMinutes(from p: CGPoint) {
        let dx = p.x - dial / 2, dy = p.y - dial / 2
        var a = atan2(dx, -dy)
        if a < 0 { a += 2 * .pi }
        var m = Int((a / (2 * .pi) * Double(maxMinutes) / 5).rounded()) * 5
        if m == 0 { m = maxMinutes }
        let clamped = max(minMinutes, min(maxMinutes, m))
        if clamped != minutes { data.dailyCarbLimitMinutes = clamped }
    }
}
