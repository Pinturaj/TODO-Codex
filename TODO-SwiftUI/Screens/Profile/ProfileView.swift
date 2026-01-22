import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("User") {
                LabeledContent("Username", value: vm.username.isEmpty ? "-" : vm.username)
                LabeledContent("Email", value: vm.email.isEmpty ? "-" : vm.email)
                LabeledContent("User ID", value: vm.userId.isEmpty ? "-" : vm.userId)
            }

            Section {
                Button(role: .destructive) {
                    vm.logout()
                    dismiss()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .navigationTitle("Profile")
        .globalGradientBackground()
    }
}
