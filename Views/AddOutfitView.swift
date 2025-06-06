import SwiftUI

struct AddOutfitView: View {
    @Environment(\.presentationMode) private var presentation
    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var name: String = ""
    @State private var season: String = ""
    @State private var date: Date = Date()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $name)
                .padding()
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(8)
                .foregroundColor(.white)
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(Color(hex: "#FFC300"))
            TextField("Season", text: $season)
                .padding()
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(8)
                .foregroundColor(.white)
            Button("Save Outfit") { save() }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FFC300"))
                .cornerRadius(8)
                .foregroundColor(.white)
            Button("Cancel") { presentation.wrappedValue.dismiss() }
                .foregroundColor(.white)
        }
        .padding(32)
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
        .alert(isPresented: $showAlert) { Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK"))) }
    }

    private func save() {
        guard let user = currentUsername, !name.isEmpty, !season.isEmpty else {
            alertMessage = "Complete fields"
            showAlert = true
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateStr = formatter.string(from: date)
        let success = CppBridge.saveOutfit(forUser: user, name: name, dateAdded: dateStr, season: season)
        if success {
            presentation.wrappedValue.dismiss()
        } else {
            alertMessage = "Failed to save"
            showAlert = true
        }
    }
}
