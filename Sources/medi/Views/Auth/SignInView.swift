import SwiftUI
import AuthenticationServices

public struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 1.0),
                    Color(red: 0.85, green: 0.85, blue: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App branding
                VStack(spacing: 20) {
                    // Logo/Icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.6, green: 0.7, blue: 0.9).opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                    }
                    
                    Text("medi")
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.4))
                    
                    Text("Find your inner peace")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Benefits
                VStack(spacing: 15) {
                    FeatureRow(icon: "timer", text: "Guided meditation sessions")
                    FeatureRow(icon: "heart.fill", text: "Track your mindfulness journey")
                    FeatureRow(icon: "icloud.fill", text: "Sync across all your devices")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.5))
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(.center)
                }
                
                // Apple Sign-In Button
                VStack(spacing: 20) {
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                // Handle successful authorization
                                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                    authManager.userID = appleIDCredential.user
                                    authManager.userEmail = appleIDCredential.email
                                    authManager.userName = appleIDCredential.fullName?.givenName
                                    authManager.isSignedIn = true
                                    authManager.errorMessage = nil
                                    
                                    // Store user data
                                    UserDefaults.standard.set(authManager.userID, forKey: "apple_user_id")
                                    if let email = authManager.userEmail {
                                        UserDefaults.standard.set(email, forKey: "user_email")
                                    }
                                    if let name = authManager.userName {
                                        UserDefaults.standard.set(name, forKey: "user_name")
                                    }
                                }
                            case .failure(let error):
                                print("Apple Sign-In failed: \(error.localizedDescription)")
                                authManager.errorMessage = "Sign-in failed. You can continue without signing in."
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(25)
                    .padding(.horizontal, 40)
                    
                    Text("Sign in to save your meditation progress")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
                        .multilineTextAlignment(.center)
                    
                    // Skip option - always available
                    Button("Continue without signing in") {
                        authManager.continueWithoutSignIn()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                    .padding(.top, 10)
                    
                    // Additional help text
                    Text("You can always sign in later from the Profile tab")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.6, green: 0.7, blue: 0.9))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.5))
            
            Spacer()
        }
    }
} 