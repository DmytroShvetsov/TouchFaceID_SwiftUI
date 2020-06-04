import SwiftUI
import Combine

extension Main {
    struct MainView: View {
        @ObservedObject var viewModel: MainVM
        
        private var name: Binding<String>
        @State private var isNameFocused = false
        
        init(viewModel: MainVM) {
            self.viewModel = viewModel
            
            name = .init(get: {
                viewModel.state.name
            }, set: {
                viewModel.send(event: .typingName($0))
            })
        }
        
        var body: some View {
            ZStack {
                Color.appBackground
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    ZStack {
                        self.background(geometry)
                        self.content(geometry)
                    }
                }
            }
            .keyboardAdaptive { $1 - max($0.size.height - $1 - $1, 0) }
            .edgesIgnoringSafeArea(.all)
        }
        
        private func background(_ geometry: GeometryProxy) -> some View {
            CustomEmptyView()
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                .onTapGesture { self.endEditing() }
        }
        
        private func content(_ geometry: GeometryProxy) -> some View  {
            VStack(alignment: .center, spacing: 0) {
                Text("User name:")
                    .font(.subheadline)
                    .foregroundColor(.appCaptionOut)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 6)
                ResponderTextField("e.g. Peter", placeholderColor: .appGray, text: self.name, textColor: .appText, isFirstResponder: self.$isNameFocused)
                    .frame(height: 38)
                    .padding([.top, .bottom], 5)
                    .padding([.leading, .trailing], 10)
                    .background(Color.appContrastBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6)
                        .stroke(lineWidth: 1)
                        .foregroundColor(.appGray))
                    .shadow(color: Color.appGreen, radius: 1)
                
                Spacer().frame(height: 10)
                
                Button(action: {
                    self.viewModel.send(event: .logout)
                }) {
                    Text("Logout")
                        .foregroundColor(.appBlue)
                        .padding(.all, 15)
                }
                
            }
            .frame(idealWidth: geometry.size.width * 0.7,
                   maxWidth: geometry.size.width * 0.7,
                   minHeight: geometry.size.height)
        }
        
        private func endEditing() {
            isNameFocused = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Main.MainView(viewModel: .init())
            .previewLayout(.device)
            .previewsPreset()
    }
}
