import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) private var presentation
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @AppStorage("currentUsername") private var currentUsername: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Crează cont")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 40)

            Group {
                TextField("Name", text: $name)
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
            }
            .padding()
            .background(Color(hex: "#2A2A2A"))
            .cornerRadius(8)
            .foregroundColor(.white)
            .autocapitalization(.none)
            .padding(.horizontal, 32)

            Button("Sign In", action: signUpTapped)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FFC300"))
                .cornerRadius(8)
                .foregroundColor(.white)
                .font(.system(.headline, weight: .semibold))
                .padding(.horizontal, 32)
                .padding(.top, 16)

            Spacer()

            Button("Cancel") {
                presentation.wrappedValue.dismiss()
            }
            .foregroundColor(.white)
            .padding(.bottom, 16)
        }
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Eroare"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signUpTapped() {
        let n = name.trimmingCharacters(in: .whitespaces)
        let u = username.trimmingCharacters(in: .whitespaces)
        let p = password

        guard !n.isEmpty && !u.isEmpty && !p.isEmpty else {
            alertMessage = "Completează toate câmpurile."
            showAlert = true
            return
        }

        if CppBridge.createUser(u, name: n, password: p) {
            currentUsername = u
            presentation.wrappedValue.dismiss()
        } else {
            alertMessage = "Username deja folosit."
            showAlert = true
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
