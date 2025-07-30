import Foundation
import AuthenticationServices
import SwiftUI

class AuthManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var userID: String?
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var showingSignIn = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    
    override init() {
        super.init()
        checkAuthStatus()
    }
    
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signOut() {
        userID = nil
        userEmail = nil
        userName = nil
        isSignedIn = false
        errorMessage = nil
        
        // Clear stored user data
        UserDefaults.standard.removeObject(forKey: "apple_user_id")
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "user_name")
    }
    
    private func checkAuthStatus() {
        // Check if user was previously signed in
        if let storedUserID = UserDefaults.standard.string(forKey: "apple_user_id") {
            userID = storedUserID
            userEmail = UserDefaults.standard.string(forKey: "user_email")
            userName = UserDefaults.standard.string(forKey: "user_name")
            isSignedIn = true
            
            // Sync profile with Supabase in the background
            if !storedUserID.hasPrefix("anonymous_") {
                Task {
                    await syncProfileWithSupabase()
                }
            }
        } else {
            // No stored user data - require sign in
            isSignedIn = false
        }
    }
    
    // MARK: - Supabase Integration
    
    @MainActor
    func syncProfileWithSupabase() async {
        guard let userId = userID, !userId.hasPrefix("anonymous_") else { return }
        
        await supabase.getOrCreateProfile(
            for: userId,
            email: userEmail,
            name: userName
        )
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            userID = appleIDCredential.user
            userEmail = appleIDCredential.email
            
            // Better name handling - combine given and family name
            if let fullName = appleIDCredential.fullName {
                if let givenName = fullName.givenName, let familyName = fullName.familyName {
                    userName = "\(givenName) \(familyName)"
                } else if let givenName = fullName.givenName {
                    userName = givenName
                } else if let familyName = fullName.familyName {
                    userName = familyName
                }
            }
            
            isSignedIn = true
            errorMessage = nil
            
            // Store user data for future sessions
            UserDefaults.standard.set(userID, forKey: "apple_user_id")
            if let email = userEmail {
                UserDefaults.standard.set(email, forKey: "user_email")
            }
            if let name = userName {
                UserDefaults.standard.set(name, forKey: "user_name")
            }
            
            // Sync with Supabase
            Task {
                await syncProfileWithSupabase()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-In failed: \(error.localizedDescription)")
        
        // Handle specific error cases
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                errorMessage = "Sign-in was canceled"
            case .failed:
                errorMessage = "Sign-in failed. Please try again."
            case .invalidResponse:
                errorMessage = "Invalid response from Apple"
            case .notHandled:
                errorMessage = "Sign-in not handled"
            case .unknown:
                errorMessage = "Unknown error occurred"
            @unknown default:
                errorMessage = "Sign-in failed"
            }
        } else {
            errorMessage = "Sign-in failed. Please try again."
        }
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first ?? UIWindow()
        return window
    }
} 