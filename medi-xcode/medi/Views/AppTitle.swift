import SwiftUI

struct AppTitle: View {
    let title: String
    let alignment: HorizontalAlignment
    let showAccent: Bool
    
    init(_ title: String, alignment: HorizontalAlignment = .center, showAccent: Bool = true) {
        self.title = title
        self.alignment = alignment
        self.showAccent = showAccent
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 32, weight: .light, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .tracking(1.2)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
            
            if showAccent {
                // Decorative accent line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60, height: 1)
                    .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
            }
        }
    }
}

// MARK: - Previews
#Preview("AppTitle - Center") {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.2, blue: 0.8),
                Color(red: 0.6, green: 0.3, blue: 0.9),
                Color(red: 0.8, green: 0.4, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            AppTitle("Profile")
            AppTitle("History")
            AppTitle("Meditate")
        }
        .padding(.top, 60)
    }
}

#Preview("AppTitle - Left Aligned") {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.2, blue: 0.8),
                Color(red: 0.6, green: 0.3, blue: 0.9),
                Color(red: 0.8, green: 0.4, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            AppTitle("Profile", alignment: .leading)
            AppTitle("History", alignment: .leading, showAccent: false)
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }
}

#Preview("AppTitle - Dynamic Type") {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.2, blue: 0.8),
                Color(red: 0.6, green: 0.3, blue: 0.9),
                Color(red: 0.8, green: 0.4, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        AppTitle("Profile")
            .padding(.top, 60)
    }
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
