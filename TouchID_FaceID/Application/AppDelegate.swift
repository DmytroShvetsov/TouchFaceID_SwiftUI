import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let applicationService = ServicesFactory.applicationService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        applicationService.didFinishLaunching()
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        applicationService.applicationWillTerminate()
    }
}
