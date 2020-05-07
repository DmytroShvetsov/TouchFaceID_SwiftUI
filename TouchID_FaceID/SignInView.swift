import SwiftUI

struct SignInView: View {
    @State private var login: String = ""
    @State private var password: String = ""
    
    @State private var isLoginFocused = false
    @State private var isPasswordFocused = false
    
    var body: some View {
        GeometryReader { geometry in
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
                    print(self.isLoginFocused)
                    print(self.isPasswordFocused)
                }) {
                    Text("Sign In")
                        .padding(16)
                }
            }
            .frame(width: geometry.size.width * 0.7,
                   height: .leastNormalMagnitude,
                   alignment: .center)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
