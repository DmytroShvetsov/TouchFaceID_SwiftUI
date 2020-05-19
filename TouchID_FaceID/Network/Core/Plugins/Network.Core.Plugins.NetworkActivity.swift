import UIKit

// MARK: - NetworkActivity
extension Network.Core.Plugins {
    final class NetworkActivity {
        
    }
}

// MARK: - PluginType
extension Network.Core.Plugins.NetworkActivity: PluginType {
    func willSend(_ request: URLRequest, target: TargetType) {
        Network.Core.Plugins.NetworkActivity.changeActivitiesCount(by: 1)
    }
    
    func didReceive(_ result: Result<Network.Common.Responses.Response, Network.Common.Error>, target: TargetType) {
        Network.Core.Plugins.NetworkActivity.changeActivitiesCount(by: -1)
    }
}

private extension Network.Core.Plugins.NetworkActivity {
    static var activitiesCount = 0
    static let lock = NSLock()
    
    static func changeActivitiesCount(by number: Int) {
        lock.lock()
        activitiesCount = max(0, activitiesCount + number)
        lock.unlock()
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = activitiesCount > 0
        }
    }
}
