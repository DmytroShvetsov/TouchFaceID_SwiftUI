import Foundation
import Combine

private typealias VM = SignIn.SignInVM
private typealias Event = SignIn.Models.Event
private typealias State = SignIn.Models.State

extension SignIn {
    final class SignInVM: ObservableObject {
        @Published private(set) var state: Models.State
        
        private var bag: Set<AnyCancellable> = .init()
        private let input = PassthroughSubject<Event, Never>()
        
        init() {
            let biometricAuth = BiometricAuth()
            let availability = biometricAuth.canEvaluatePolicy() && UserDefaults.biometricAuthAllowed
            
            state = .init(login: "",
                          password: "",
                          biometricAuthType: biometricAuth.biometricType(),
                          biometricAuthAvailable: availability,
                          state: .idle)

            Publishers.system(
                initial: state,
                reduce: Self.reduce,
                scheduler: RunLoop.main,
                feedbacks: [
                    Self.input(input: input.eraseToAnyPublisher()),
                    Self.authorization(),
                    Self.previousUserLogin()
                ],
                skipTransitionStates: true,
                skipInitialState: true,
                removeDuplicates: true
            )
                .assignWeak(to: \.state, on: self)
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
            case .idle:
                state.state = .default
                fallthrough
            
            case .default:
                switch event {
                    case .previousUserLogin(let login):
                        guard state.login != login else { break }
                        state.login = login
                        
                    default:
                        break
                }
            
                fallthrough
            
            case
                .authorized,
                .error:
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
                        state.state = .authorization(biometric: false)
                    
                    case .viewEvent(.signInViaBiometricAuth):
                        state.state = .authorization(biometric: true)
                    
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
            guard case .authorization(let biometric) = state.state else { return Empty().eraseToAnyPublisher() }
            
            if biometric {
                return ServicesFactory.authService().signInViaBiometricAuth()
                    .map { _ in .authorized }
                    .catch { Just(.failed($0)) }
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            } else {
                return ServicesFactory.authService().signIn(login: state.login, password: state.password)
                    .map {
                        switch $0 {
                            case .success:
                                return .authorized
                            case .failed(let error):
                                return .failed(error)
                        }
                }
                .replaceError(with: .failed(AppError(error: "Error. Please try again.")))
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            }
        }
    }

    static func previousUserLogin() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .idle = state.state else { return Empty().eraseToAnyPublisher() }
            
            return ServicesFactory.userService().user
                .map { .previousUserLogin($0.login) }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
    
    static func input(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
