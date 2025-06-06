import SwiftUI

struct Outfit: Identifiable {
    let id: Int
    let name: String
    let season: String
    let image: UIImage?
}
struct OutfitsView: View {
    @State private var outfits: [Outfit] = []
    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var showAdd: Bool = false

    var body: some View {
        NavigationView {
            List(outfits) { o in
                HStack {
                    if let img = o.image {
                        Image(uiImage: img).resizable().frame(width: 80, height: 80).cornerRadius(8)
                    } else {
                        Rectangle().fill(Color.gray).frame(width: 80, height: 80).cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(o.name).foregroundColor(.white).font(.headline)
                        Text(o.season).foregroundColor(Color(hex: "#CCCCCC")).font(.subheadline)
                    }
                }
                .listRowBackground(Color(hex: "#252525"))
            }
            .background(Color(hex: "#1E1E1E").ignoresSafeArea())
            .navigationTitle("Outfits")
            .toolbar { Button(action: { showAdd = true }) { Image(systemName: "plus") } }
            .sheet(isPresented: $showAdd) { AddOutfitView() }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let user = currentUsername,
              let arr = CppBridge.fetchOutfits(forUser: user) as? [[String: Any]] else { return }
        outfits = arr.enumerated().map { idx, dict in
            Outfit(
                id: idx,
                name: dict["name"] as? String ?? "",
                season: dict["season"] as? String ?? "",
                image: {
                    guard let d = dict["image"] as? Data else { return nil }
                    return UIImage(data: d)
                }()
            )
        }
    }
}
