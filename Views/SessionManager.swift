import Foundation
import Combine

final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    @Published var currentUsername: String? {
        didSet {
            UserDefaults.standard.set(currentUsername, forKey: "currentUsername")
        }
    }
    private init() {
        currentUsername = UserDefaults.standard.string(forKey: "currentUsername")
    }
}
