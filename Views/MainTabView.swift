import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            ClosetView()
                .tabItem { Label("Closet", systemImage: "folder.fill") }
            
            OutfitsView()
                .tabItem { Label("Outfits", systemImage: "figure.walk") }
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .accentColor(.yellow)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
