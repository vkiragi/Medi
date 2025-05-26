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
    
    func continueWithoutSignIn() {
        // Allow anonymous usage - user can still use the app
        isSignedIn = true
        userID = "anonymous_\(UUID().uuidString)"
        errorMessage = nil
    }
    
    private func checkAuthStatus() {
        // Check if user was previously signed in
        if let storedUserID = UserDefaults.standard.string(forKey: "apple_user_id") {
            userID = storedUserID
            userEmail = UserDefaults.standard.string(forKey: "user_email")
            userName = UserDefaults.standard.string(forKey: "user_name")
            isSignedIn = true
        }
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            userID = appleIDCredential.user
            userEmail = appleIDCredential.email
            userName = appleIDCredential.fullName?.givenName
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
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
} 