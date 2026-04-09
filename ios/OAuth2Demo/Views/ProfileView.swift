import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            List {
                if let user = authViewModel.user {
                    Section("Profile") {
                        row(label: "Username", value: user.preferredUsername)
                        row(label: "Name", value: user.name)
                        row(label: "Email", value: user.email)
                        row(label: "Email Verified", value: user.emailVerified.map { $0 ? "Yes" : "No" })
                        row(label: "Subject", value: user.sub)
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        Task {
                            await authViewModel.logout()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }

    private func row(label: String, value: String?) -> some View {
        LabeledContent(label, value: value ?? "—")
    }
}
