import Combine

// MARK: - system
extension Publishers {
    static func system<State, Event, Scheduler: Combine.Scheduler>(
        initial: State,
        reduce: @escaping (State, Event) -> State,
        scheduler: Scheduler,
        feedbacks: [Feedback<State, Event>]
    ) -> AnyPublisher<State, Never> {
        
        let state = CurrentValueSubject<State, Never>(initial)
        
        let events = feedbacks.map { feedback in feedback.run(state.eraseToAnyPublisher()) }
        
        return Deferred {
            Publishers.MergeMany(events)
                .receive(on: scheduler)
                .scan(initial, reduce)
                .handleEvents(receiveOutput: state.send)
                .receive(on: scheduler)
                .prepend(initial)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - system State:Equatable
extension Publishers {
    static func system<State: Equatable, Event, Scheduler: Combine.Scheduler>(
        initial: State,
        reduce: @escaping (State, Event) -> State,
        scheduler: Scheduler,
        feedbacks: [Feedback<State, Event>],
        skipTransitionStates: Bool,
        skipInitialState: Bool,
        removeDuplicates: Bool
    ) -> AnyPublisher<State, Never> {
        
        let state = CurrentValueSubject<State, Never>(initial)
        
        let events = feedbacks.map { feedback in feedback.run(state.eraseToAnyPublisher()) }
        
        return Deferred<AnyPublisher<State, Never>> {
            var publisher: AnyPublisher<State, Never> = Publishers.MergeMany(events)
                .receive(on: scheduler)
                .scan(initial, reduce)
                .handleEvents(receiveOutput: state.send)
                .receive(on: scheduler)
                .prepend(initial)
                .eraseToAnyPublisher()
            
            if skipTransitionStates {
                publisher = publisher
                    .map { _ in state.value }
                    .eraseToAnyPublisher()
            }
            
            if removeDuplicates {
                publisher = publisher
                    .removeDuplicates()
                    .eraseToAnyPublisher()
            }
            
            if skipInitialState {
                publisher = publisher
                    .dropFirst()
                    .eraseToAnyPublisher()
            }
            
            return publisher
        }
        .eraseToAnyPublisher()
    }
}
