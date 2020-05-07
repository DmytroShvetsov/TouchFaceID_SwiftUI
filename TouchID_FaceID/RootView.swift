import SwiftUI

struct RootView: View {
    @ObservedObject var authProvider: AuthProvider
    
    var body: some View {
        Group {
            if authProvider.isAuthorized {
                MainView()
            } else {
                SignInView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authProvider: .init())
    }
}
