import SwiftUI

final class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard  let windowScene = scene as? UIWindowScene else { return }
        
        let mainView = MainView()
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: mainView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
