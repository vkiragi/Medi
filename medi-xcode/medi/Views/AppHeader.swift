import SwiftUI

struct AppHeader: View {
    let title: String
    var subtitle: String? = nil
    var compact: Bool = true   // compact by default

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let baseSize: CGFloat = compact ? 28 : 32
        let fontSize: CGFloat = typeSize.isAccessibilitySize ? baseSize + 2 : baseSize

        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: fontSize, weight: .light, design: .rounded))
                .tracking(0.8)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                .frame(maxWidth: .infinity, alignment: .center)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.top, 16)      // compact top padding (replace old ~60)
        .padding(.bottom, 8)    // small breathing room below title
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.4, green: 0.2, blue: 0.8), Color(red: 0.6, green: 0.4, blue: 1.0)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            AppHeader(title: "Medi")
            AppHeader(title: "Profile", subtitle: "Your meditation journey")
            AppHeader(title: "Insights", compact: false)
        }
    }
}
