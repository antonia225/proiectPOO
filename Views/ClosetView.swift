import SwiftUI

struct ClothingItem: Identifiable {
    let id: Int
    let category: String
    let color: String
    let image: UIImage?
}
struct ClosetView: View {
    @State private var items: [ClothingItem] = []
    @AppStorage("currentUsername") private var currentUsername: String?
    @State private var showAdd: Bool = false

    var body: some View {
        NavigationView {
            List(items) { item in
                HStack {
                    if let img = item.image {
                        Image(uiImage: img).resizable().frame(width: 60, height: 60).cornerRadius(8)
                    } else {
                        Rectangle().fill(Color.gray).frame(width: 60, height: 60).cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(item.category).foregroundColor(.white).font(.headline)
                        Text(item.color).foregroundColor(Color(hex: "#CCCCCC")).font(.subheadline)
                    }
                }
                .listRowBackground(Color(hex: "#252525"))
            }
            .background(Color(hex: "#1E1E1E").ignoresSafeArea())
            .navigationTitle("Closet")
            .toolbar { Button(action: { showAdd = true }) { Image(systemName: "plus") } }
            .sheet(isPresented: $showAdd) { AddItemView() }
            .onAppear(perform: load)
        }
    }

    private func load() {
        guard let user = currentUsername,
              let arr = CppBridge.fetchClothingItems(forUser: user) as? [[String: Any]] else { return }
        items = arr.enumerated().map { idx, dict in
            ClothingItem(
                id: idx,
                category: dict["category"] as? String ?? "",
                color: dict["color"] as? String ?? "",
                image: {
                    guard let d = dict["image"] as? Data else { return nil }
                    return UIImage(data: d)
                }()
            )
        }
    }
}
