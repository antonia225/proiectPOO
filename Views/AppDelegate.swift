import UIKit
import CoreData

@objcMembers
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?    // if you ever use UIKit windows elsewhere

  // Expose your Core Data stack to Obj-C
  var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DressDiary")
    container.loadPersistentStores { store, error in
      if let e = error {
        fatalError("Unresolved Core Data error: \(e)")
      }
    }
    return container
  }()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    return true
  }
}
