import SwiftUI

struct PrivacyPolicyView: View {
    @Binding var didAgree: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Privacy & AI Policy")
                    .font(.largeTitle)
                    .bold()

                Text("")
                Text("")
                Text("**How We Use Your Data**\n\n- Your meditation and mood data is stored securely on your device.\n- If you use our AI-powered features (like custom plans or insights), your data will be sent to OpenAI’s servers for processing.\n- OpenAI does not use your data to train their models, but may store it temporarily for abuse monitoring and debugging.\n- We do not share your data with any other third parties.\n\n**Your Choices**\n\n- You can use the app without AI features if you prefer.\n- You can review or delete your data at any time in the app settings.\n\n**Security**\n\n- We take reasonable steps to protect your data.\n- However, no system is 100% secure. Please use the app at your own discretion.\n\n**Legal**\n\n- By using this app, you agree to our Privacy Policy and Terms of Service.\n- This app is not intended for medical diagnosis or treatment.\n\n**Contact**\n\n- For questions, contact us at support@yourapp.com.")
                    .font(.body)
                    .padding(.top, 8)

                Toggle(isOn: $didAgree) {
                    Text("I have read and agree to the Privacy & AI Policy")
                        .fontWeight(.medium)
                }
                .padding(.top, 24)
            }
            .padding()
        }
    }
}