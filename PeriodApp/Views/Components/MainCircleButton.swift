import SwiftUI

/// The large circular primary action button on the home screen.
struct MainCircleButton: View {
    let state: MainCircleButtonState
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(state.fillGradient)
                    .frame(width: 220, height: 220)
                    .shadow(color: state.shadowColor, radius: 20, x: 0, y: 10)
                    .scaleEffect(isPressed ? 0.94 : 1.0)

                VStack(spacing: 8) {
                    Image(systemName: state.iconName)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                    Text(state.label)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(state.hapticFeedback, trigger: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: state)
    }
}

// MARK: - State

enum MainCircleButtonState: Equatable {
    case noPeriod
    case periodInProgress
    case waitingForNextCycle

    var label: String {
        switch self {
        case .noPeriod:           return "Start Period"
        case .periodInProgress:   return "Period\nIn Progress"
        case .waitingForNextCycle: return "Next Cycle\nExpected"
        }
    }

    var iconName: String {
        switch self {
        case .noPeriod:           return "plus.circle"
        case .periodInProgress:   return "drop.fill"
        case .waitingForNextCycle: return "clock"
        }
    }

    var fillGradient: LinearGradient {
        switch self {
        case .noPeriod:
            return LinearGradient(
                colors: [Color.pink.opacity(0.8), Color.pink],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case .periodInProgress:
            return LinearGradient(
                colors: [Color(red: 0.9, green: 0.1, blue: 0.2),
                         Color(red: 0.7, green: 0.05, blue: 0.15)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case .waitingForNextCycle:
            return LinearGradient(
                colors: [Color.pink.opacity(0.5), Color.pink.opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var shadowColor: Color {
        switch self {
        case .noPeriod:           return .pink.opacity(0.4)
        case .periodInProgress:   return Color(red: 0.8, green: 0.1, blue: 0.1).opacity(0.5)
        case .waitingForNextCycle: return .pink.opacity(0.2)
        }
    }

    var hapticFeedback: SensoryFeedback {
        switch self {
        case .noPeriod:           return .impact(weight: .heavy)
        case .periodInProgress:   return .success
        case .waitingForNextCycle: return .selection
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        MainCircleButton(state: .noPeriod, action: {})
        MainCircleButton(state: .periodInProgress, action: {})
        MainCircleButton(state: .waitingForNextCycle, action: {})
    }
    .padding()
}
