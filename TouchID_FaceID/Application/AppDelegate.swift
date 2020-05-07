import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
          let sceneConfiguration = UISceneConfiguration()
          sceneConfiguration.delegateClass = MainSceneDelegate.self
          return sceneConfiguration
    }
    
}
