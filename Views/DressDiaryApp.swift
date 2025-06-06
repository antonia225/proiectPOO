import SwiftUI

@main
struct DressDiaryApp: App {
  // hook up our legacy AppDelegate for Core Data
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @AppStorage("currentUsername") private var currentUsername: String?

  var body: some Scene {
    WindowGroup {
      if let user = currentUsername, !user.isEmpty {
        MainTabView()
      } else {
        LoginView()
      }
    }
  }
}
