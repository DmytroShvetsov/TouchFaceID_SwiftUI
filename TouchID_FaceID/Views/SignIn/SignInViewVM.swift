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
            case .default:
                switch event {
                    case .viewEvent(.typingLogin(let txt)):
                        guard state.login != txt else { break }
                        state.login = txt
                    
                    case .viewEvent(.typingPassword(let txt)):
                        guard state.password != txt else { break }
                        state.password = txt
                    
                    case .viewEvent(.signIn):
                        if case .authorization = state.state { break }
                        state.state = .authorization(proceeding: false)
                    
                    default:
                        break
                }
            
            case .authorization(false):
                switch event {
                    case .authorizationBegun:
                        state.state = .authorization(proceeding: true)
                    
                    default:
                        break
                }
            
            default:
                break
        }

        return state
    }

//    static func whenLoading() -> Feedback<State, Event> {
//        Feedback { (state: State) -> AnyPublisher<Event, Never> in
//            guard case .loading = state else { return Empty().eraseToAnyPublisher() }
//
//            return MoviesAPI.trending()
//                .map { $0.results.map(ListItem.init) }
//                .map(Event.onMoviesLoaded)
//                .catch { Just(Event.onFailedToLoadMovies($0)) }
//                .eraseToAnyPublisher()
//        }
//    }
    
    static func authorization() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .authorization(let proceeding) = state.state, !proceeding else { return Empty().eraseToAnyPublisher() }
            print(213)
            return CurrentValueSubject(.authorizationBegun).eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
