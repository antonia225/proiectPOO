import SwiftUI

struct ProfileView: View {
    @AppStorage("currentUsername") private var currentUsername: String?
    @Environment(\.presentationMode) private var presentation

    var body: some View {
        VStack(spacing: 32) {
            if let user = currentUsername {
                Image("placeholderAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .background(Circle().fill(Color(hex: "#2A2A2A")))
                Text(user)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
                Button("Logout") {
                    currentUsername = nil
                    presentation.wrappedValue.dismiss()
                }
                .frame(width: 200, height: 50)
                .background(Color(hex: "#FFC300"))
                .cornerRadius(8)
                .foregroundColor(.white)
            } else {
                Text("Guest")
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.top, 80)
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
    }
}
