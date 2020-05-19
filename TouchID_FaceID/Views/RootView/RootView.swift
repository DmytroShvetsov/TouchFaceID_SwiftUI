import SwiftUI

struct RootView: View {
    @ObservedObject var authProvider: AuthProvider
    
    var body: some View {
        Group {
            if authProvider.isAuthorized {
                MainView()
            } else {
                SignIn.SignInView(viewModel: .init())
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(authProvider: .init())
    }
}
