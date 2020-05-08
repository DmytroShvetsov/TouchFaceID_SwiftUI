import SwiftUI

struct SignInView: View {
    @State private var login: String = ""
    @State private var password: String = ""
    
    @State private var isLoginFocused = false
    @State private var isPasswordFocused = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                ZStack {
                    CustomEmptyView()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                        .onTapGesture { self.endEditing() }
                    VStack(alignment: .center) {
                        VStack(spacing: 0) {
                            ResponderTextField("Login", text: self.$login, isFirstResponder: self.$isLoginFocused)
                                .frame(height: 38)
                                .padding([.top, .bottom], 5)
                                .padding([.leading, .trailing], 10)
                                .onTapGesture { self.isLoginFocused = true }
                            Divider()
                                .padding(.trailing, -10)
                                .frame(height: 1, alignment: .trailing)
                                .foregroundColor(.gray)
                            ResponderTextField("Password", text: self.$password, isFirstResponder: self.$isPasswordFocused)
                                .frame(height: 38)
                                .padding([.top, .bottom], 5)
                                .padding([.leading, .trailing], 10)
                                .onTapGesture { self.isPasswordFocused = true }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color.gray))
                        .shadow(color: .green, radius: 2)
                        
                        Button(action: {
                            self.endEditing()
                        }) {
                            Text("Sign In")
                                .padding(16)
                        }
                    }
                    .frame(idealWidth: geometry.size.width * 0.7,
                           maxWidth: geometry.size.width * 0.7,
                           minHeight: geometry.size.height)
                        .frame(width: geometry.size.width)
                }
            }
        }
        .keyboardAdaptive()
        .background(Color.init(white: 0.95))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func endEditing() {
        isLoginFocused = false
        isPasswordFocused = false
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
