import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @AppStorage("currentUsername") private var currentUsername: String?

    var body: some View {
        VStack(spacing: 32) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top, 40)

            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 32)

            Button(action: logInTapped) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FFC300"))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .font(.system(.headline, weight: .semibold))
            }
            .padding(.horizontal, 32)

            Spacer()

            Button("Sign In") {
                // prezintă ecranul de Sign Up
                showingSignUp = true
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .padding(.bottom, 16)
        }
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Eroare"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    @State private var showingSignUp = false

    private func logInTapped() {
        let user = username.trimmingCharacters(in: .whitespaces)
        let pass = password

        guard !user.isEmpty && !pass.isEmpty else {
            alertMessage = "Completează username și parolă."
            showAlert = true
            return
        }

        if CppBridge.loginUser(user, password: pass) != nil {
            currentUsername = user
        } else {
            alertMessage = "Username sau parolă incorectă."
            showAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
