import Foundation
import Combine

private typealias VM = Main.MainVM
private typealias Event = Main.Models.Event
private typealias State = Main.Models.State

extension Main {
    final class MainVM: ObservableObject {
        @Published private(set) var state: Models.State

        private var bag: Set<AnyCancellable> = .init()
        private let input = PassthroughSubject<Event, Never>()

        init() {
            state = .init(name: "", biometricAuthAllowed: UserDefaults.biometricAuthAllowed, state: .default)

            Publishers.system(
                initial: state,
                reduce: Self.reduce,
                scheduler: RunLoop.main,
                feedbacks: [
                    Self.input(input: input.eraseToAnyPublisher()),
                    Self.userName(),
                    Self.updateUserName(),
                    Self.biometricAuthAllowed(),
                    Self.updateBiometricAuthAllowance(),
                    Self.logout()
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
    func send(event: Main.Models.ViewEvent) {
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

        switch event {
            case .viewEvent(let event):
                switch event {
                    case .typingName(let name):
                        guard state.name != name else { break }
                        state.name = name
                        state.state = .savingUserName

                    case .toggleBiometricAuthAllowance:
                        state.biometricAuthAllowed.toggle()
                        state.state = .savingBiometricAuthAllowance

                    case .logout:
                        state.state = .logout
                }

            case .updateUserName(let name):
                guard state.name != name else { break }
                state.name = name
                state.state = state.state == .savingUserName ? .default : state.state

            case .updateBiometricAuthAllowance(let isAllowed):
                state.biometricAuthAllowed = isAllowed
                state.state = state.state == .savingBiometricAuthAllowance ? .default : state.state

            case .userNameSaved:
                state.state = state.state == .savingUserName ? .default : state.state

            case .logoutExecuted:
                state.state = .default
        }
        
        return state
    }

    static func userName() -> Feedback<State, Event> {
        Feedback { _ in
            ServicesFactory.userService().user
                .map { $0.info.name ?? "" }
                .map(Event.updateUserName)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }

    static func updateUserName() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard state.state == .savingUserName else { return Empty().eraseToAnyPublisher() }

            ServicesFactory.userService().updateUserInfo(.init(name: state.name))

            return Just(.userNameSaved)
                .eraseToAnyPublisher()
        }
    }

    static func biometricAuthAllowed() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            UserDefaults
                .publisher(for: .biometricAuthAllowed)
                .map(Event.updateBiometricAuthAllowance)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }

    static func updateBiometricAuthAllowance() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard state.state == .savingBiometricAuthAllowance else { return Empty().eraseToAnyPublisher() }

            UserDefaults.biometricAuthAllowed = state.biometricAuthAllowed

            return Just(.updateBiometricAuthAllowance(state.biometricAuthAllowed))
                .eraseToAnyPublisher()
        }
    }

    static func logout() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard state.state == .logout else { return Empty().eraseToAnyPublisher() }

            ServicesFactory.userService().logout()

            return Just(.logoutExecuted)
                .eraseToAnyPublisher()
        }
    }

    static func input(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
