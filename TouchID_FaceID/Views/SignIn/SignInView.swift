import SwiftUI
import Combine

extension SignIn {
    struct SignInView: View {
        @ObservedObject var viewModel: SignInVM
        
        private var login: Binding<String>
        private var password: Binding<String>
        
        @State private var isLoginFocused = false
        @State private var isPasswordFocused = false
        
        init(viewModel: SignInVM) {
            self.viewModel = viewModel
            
            login = .init(get: {
                viewModel.state.login
            }) {
                viewModel.send(event: .typingLogin($0))
            }
            
            password = .init(get: {
                viewModel.state.password
            }) {
                viewModel.send(event: .typingPassword($0))
            }
        }
        
        var body: some View {
            defer { endEditingIfNeeded() }
            return ZStack {
                Color.appBackground
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        ZStack {
                            self.background(geometry)
                            self.content(geometry)
                        }
                    }
                }
                .keyboardAdaptive { $1 - max($0.size.height - $1 - $1, 0) }
                .edgesIgnoringSafeArea([.bottom, .top])
            }
        }
        
        private func background(_ geometry: GeometryProxy) -> some View {
            CustomEmptyView()
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                .onTapGesture { self.endEditing() }
        }
        
        private func content(_ geometry: GeometryProxy) -> some View {
            VStack(alignment: .center) {
                VStack(spacing: 0) {
                    self.textField("Login", text: self.login, isFirstResponder: self.$isLoginFocused)
                        .onTapGesture { self.isLoginFocused = true }
                    Divider()
                        .padding(.trailing, -10)
                        .frame(height: 1, alignment: .trailing)
                        .foregroundColor(.appGray)
                    self.textField("Password", text: self.password, isFirstResponder: self.$isPasswordFocused)
                        .onTapGesture { self.isPasswordFocused = true }
                    
                }
                .background(Color.appContrastBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(lineWidth: 1)
                .foregroundColor(.appGray))
                .shadow(color: viewModel.state.state.error == nil ? .appGreen : .appRed, radius: 2)
                .overlay(LoaderView(isAnimating: .init(get: { () -> Bool in
                    guard case .authorization = self.viewModel.state.state else { return false }
                    return true
                }, set: {_ in}))
                    .clipShape(RoundedRectangle(cornerRadius: 6)))
                
                errorView
                
                Button(action: {
                    self.viewModel.send(event: .signIn)
                }) {
                    Text("Sign In")
                        .foregroundColor(.appBlue)
                        .padding(.top, 14)
                        .padding([.leading, .bottom, .trailing], 16)
                    
                }
            }
            .frame(idealWidth: geometry.size.width * 0.7,
                   maxWidth: geometry.size.width * 0.7,
                   minHeight: geometry.size.height)
                .frame(width: geometry.size.width)
        }
        
        private func textField(_ placeholder: String, text: Binding<String>, isFirstResponder: Binding<Bool>) -> some View {
            ResponderTextField(placeholder, placeholderColor: .appGray, text: text, textColor: .appText, isFirstResponder: isFirstResponder)
                .frame(height: 38)
                .padding([.top, .bottom], 5)
                .padding([.leading, .trailing], 10)
        }
        
        private var errorView: some View {
            Text(viewModel.state.state.error?.localizedDescription ?? "")
                .font(.caption)
                .foregroundColor(Color.appRed)
                .padding(.top, 2)
                .opacity(viewModel.state.state.error == nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.15))
                .clipped()
        }
        
        private func endEditingIfNeeded() {
            guard case .authorization = self.viewModel.state.state else { return }
            DispatchQueue.main.async { self.endEditing() }
        }
        
        private func endEditing() {
            isLoginFocused = false
            isPasswordFocused = false
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignIn.SignInView(viewModel: .init())
            .previewLayout(.device)
            .previewsPreset()
    }
}
