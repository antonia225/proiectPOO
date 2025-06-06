import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) private var presentation
    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var color: String = ""
    @State private var materials: String = ""
    @State private var subcategory: String = ""
    @State private var selectedBase: Int = 0
    @State private var pantsLength: String = ""
    @State private var pantsWaist: String = ""
    @State private var jacketWaterproof: Bool = false
    @State private var topSleeve: String = ""
    @State private var topNeck: String = ""
    @State private var suitLength: String = ""
    @State private var suitWaist: String = ""
    @State private var suitWaterproof: Bool = false
    @State private var suitMatchy: Bool = false
    @State private var suitPattern: String = ""
    @State private var image: UIImage? = nil
    @State private var showPicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    private let categories = ["pants", "jacket", "top", "suit"]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextField("Color", text: $color)
                    .padding()
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(8)
                    .foregroundColor(.white)

                TextField("Materials (comma-separated)", text: $materials)
                    .padding()
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(8)
                    .foregroundColor(.white)

                Picker("Category", selection: $selectedBase) {
                    Text("Pants").tag(0)
                    Text("Jacket").tag(1)
                    Text("Top").tag(2)
                    Text("Suit").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 8)

                Group {
                    switch selectedBase {
                    case 0:
                        TextField("Pants Length", text: $pantsLength)
                            .keyboardType(.decimalPad)
                        TextField("Pants Waist", text: $pantsWaist)
                    case 1:
                        Toggle("Waterproof", isOn: $jacketWaterproof)
                    case 2:
                        TextField("Sleeve Length", text: $topSleeve)
                            .keyboardType(.decimalPad)
                        TextField("Neck", text: $topNeck)
                    case 3:
                        TextField("Suit Length", text: $suitLength)
                            .keyboardType(.decimalPad)
                        TextField("Suit Waist", text: $suitWaist)
                        Toggle("Waterproof", isOn: $suitWaterproof)
                        Toggle("Matchy", isOn: $suitMatchy)
                        TextField("Pattern", text: $suitPattern)
                    default:
                        EmptyView()
                    }
                }
                .padding()
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(8)
                .foregroundColor(.white)

                TextField("Subcategory", text: $subcategory)
                    .padding()
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(8)
                    .foregroundColor(.white)

                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color(hex: "#2A2A2A"))
                        .frame(height: 120)
                        .cornerRadius(8)
                }

                Button("Select Image") {
                    showPicker = true
                }
                .foregroundColor(.white)
                .sheet(isPresented: $showPicker) {
                    ImagePicker(image: $image)
                }

                Button("Save Item") {
                    save()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FFC300"))
                .cornerRadius(8)
                .foregroundColor(.white)

                Button("Cancel") {
                    presentation.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            }
            .padding(32)
        }
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func save() {
        guard let user = currentUsername,
              !color.isEmpty,
              !materials.isEmpty,
              !subcategory.isEmpty,
              let img = image,
              let data = img.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Complete fields and select an image"
            showAlert = true
            return
        }
        let mats = materials.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        let cat = categories[selectedBase]
        let success = CppBridge.saveClothingItem(
            forUser: user,
            color: color,
            materials: mats,
            category: cat,
            subcategory: subcategory,
            pantLungime: Float(pantsLength) ?? 0,
            pantTalie: pantsWaist,
            jacketWaterproof: jacketWaterproof,
            topLungimeManeca: Double(topSleeve) ?? 0,
            topDecolteu: topNeck,
            suitLungime: Float(suitLength) ?? 0,
            suitTalie: suitWaist,
            suitWaterproof: suitWaterproof,
            suitIsMatchy: suitMatchy,
            suitPattern: suitPattern,
            image: data
        )
        if success {
            presentation.wrappedValue.dismiss()
        } else {
            alertMessage = "Failed to save"
            showAlert = true
        }
    }
}
