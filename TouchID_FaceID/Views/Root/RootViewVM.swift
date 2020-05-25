import Foundation
import Combine

private typealias VM = Root.RootVM
private typealias Event = Root.Models.Event
private typealias State = Root.Models.State

extension Root {
    final class RootVM: ObservableObject {
        @Published var state: Models.State
        
        private var bag: Set<AnyCancellable> = .init()
        
        init() {
            state = .default
            
            Publishers.system(
                initial: state,
                reduce: Self.reduce,
                scheduler: RunLoop.main,
                feedbacks: [
                    Self.isAuthorized()
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

// MARK: - State Machine
private extension VM {
    static func reduce(_ state: State, _ event: Event) -> State {
        var state = state
        
        switch event {
            case .authorized(true):
                state = .authorized
                
            case .authorized(false):
                state = .notAuthorized
        }
        
        return state
    }
    
    static func isAuthorized() -> Feedback<State, Event> {
        Feedback { _ in
            ServicesFactory.authService().isAuthorized
                .receive(on: DispatchQueue.main)
                .map(Event.authorized)
                .eraseToAnyPublisher()
        }
    }
}
