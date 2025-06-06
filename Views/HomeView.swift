import SwiftUI

struct HomeView: View {
    @State private var suggestion: (name: String, season: String, image: UIImage)?
    @AppStorage("currentUsername") private var currentUsername: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Bună, \(currentUsername ?? "")")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button { /* notificări */ } label: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            VStack(alignment: .leading) {
                if let s = suggestion {
                    Image(uiImage: s.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(8)
                    Text(s.name)
                        .font(.system(.headline))
                        .foregroundColor(.white)
                    Text(s.season)
                        .font(.system(.subheadline))
                        .foregroundColor(Color(hex: "#CCCCCC"))
                } else {
                    Image("placeholderCard")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(8)
                    Text("Nicio recomandare azi")
                        .foregroundColor(.white)
                    Text("Încarcă mai întâi un outfit pentru sezonul curent.")
                        .foregroundColor(Color(hex: "#CCCCCC"))
                }
            }
            .padding()
            .background(Color(hex: "#252525"))
            .cornerRadius(12)
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
        .onAppear(perform: loadSuggestion)
    }

    private func loadSuggestion() {
        guard let user = currentUsername,
              let dict = CppBridge.getTodaySuggestion(forUser: user) as? [String: Any],
              let name = dict["name"] as? String,
              let season = dict["season"] as? String,
              let data = dict["image"] as? Data,
              let img = UIImage(data: data)
        else {
            suggestion = nil
            return
        }
        suggestion = (name: name, season: season, image: img)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
