import Foundation
import Combine

private typealias VM = SignIn.SignInVM
private typealias Event = SignIn.Models.Event
private typealias State = SignIn.Models.State

extension SignIn {
    final class SignInVM: ObservableObject {
        @Published var state: Models.State
        
        private var bag: Set<AnyCancellable> = .init()
        private let input = PassthroughSubject<Event, Never>()
        
        init() {
            state = .init(login: "", password: "", state: .default)
            
            Publishers.system(
                       initial: state,
                       reduce: Self.reduce,
                       scheduler: RunLoop.main,
                       feedbacks: [
                           Self.userInput(input: input.eraseToAnyPublisher()),
                           Self.authorization()
                       ]
                   )
                   .assign(to: \.state, on: self)
                   .store(in: &bag)
        }
    }
}

extension VM {
    func send(event: SignIn.Models.ViewEvent) {
        send(event: .viewEvent(event))
    }
    
    private func send(event: Event) {
        input.send(event)
    }
}

// MARK: - State Machine
private extension VM {
    static func reduce(_ state: State, _ event: Event) -> State {
        var state = state
        
        switch state.state {
            case
                .authorized,
                .error,
                .default:
                switch event {
                    case .viewEvent(.typingLogin(let txt)):
                        guard state.login != txt else { break }
                        state.login = txt
                        state.state = .default
                    
                    case .viewEvent(.typingPassword(let txt)):
                        guard state.password != txt else { break }
                        state.password = txt
                        state.state = .default
                    
                    case .viewEvent(.signIn):
                        guard !state.login.isEmpty else {
                            state.state = .error(AppError.init(error: "Login should not be empty."))
                            break
                        }
                        guard !state.password.isEmpty else {
                            state.state = .error(AppError.init(error: "Password should not be empty."))
                            break
                        }
                        state.state = .authorization
                    
                    default:
                        break
                }
            
            case .authorization:
                switch event {
                    case .authorized:
                        state.state = .authorized
                    
                    case .failed(let error):
                        state.state = .error(error)
                    
                    default:
                        break
                }
        }

        return state
    }
    
    static func authorization() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .authorization = state.state else { return Empty().eraseToAnyPublisher() }
            
            return Network.SampleProvider.signIn(login: state.login, password: state.password)
                .map {
                    switch $0 {
                        case .success(let token):
                            return Event.authorized(token)
                        case .failed(let error):
                            return Event.failed(error)
                    }
            }
            .delay(for: .seconds(1), scheduler: DispatchQueue.main) // MARK: - for showcase purposes;
            .replaceError(with: .authorized("token")) // MARK: - for showcase purposes;
            .replaceError(with: .failed(AppError(error: "Error. Please try again.")))
            .eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
