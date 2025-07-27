import Foundation
import AuthenticationServices
import SwiftUI
import Supabase
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class AuthManager: NSObject, ObservableObject {
    @Published public var isSignedIn = false
    @Published public var userID: String?
    @Published public var userEmail: String?
    @Published public var userName: String?
    @Published public var showingSignIn = false
    @Published public var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    
    public override init() {
        super.init()
        checkAuthStatus()
    }
    
    public func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    public func signOut() {
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
    
    public func continueWithoutSignIn() {
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
            
            // Sync profile with Supabase in the background
            if !storedUserID.hasPrefix("anonymous_") {
                Task {
                    await syncProfileWithSupabase()
                }
            }
        } else {
            // No stored user data - create anonymous user for immediate app usage
            continueWithoutSignIn()
        }
    }
    
    // MARK: - Supabase Integration
    
    @MainActor
    public func syncProfileWithSupabase() async {
        guard let userId = userID, !userId.hasPrefix("anonymous_") else { return }
        
        await supabase.getOrCreateProfile(
            for: userId,
            email: userEmail,
            name: userName
        )
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
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
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
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
            case .notInteractive:
                errorMessage = "Sign-in not interactive"
            case .matchedExcludedCredential:
                errorMessage = "Credential excluded"
            case .credentialImport:
                errorMessage = "Credential import failed"
            case .credentialExport:
                errorMessage = "Credential export failed"
            @unknown default:
                errorMessage = "Sign-in failed"
            }
        } else {
            errorMessage = "Sign-in failed. Please try again."
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if canImport(UIKit)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first ?? UIWindow()
        return window
        #else
        // For macOS or other platforms - return a basic NSWindow
        return NSWindow()
        #endif
    }
} 