import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("OAuth2 Demo")
                    .font(.largeTitle.bold())

                Text("Sign in with Keycloak using PKCE")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let error = authViewModel.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task {
                    await authViewModel.login()
                }
            } label: {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(authViewModel.isLoading)
            .padding(.horizontal, 32)

            Spacer()
                .frame(height: 48)
        }
    }
}
