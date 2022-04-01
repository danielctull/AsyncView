import SwiftUI

public struct AsyncView<Value, Initial: View, Success: View, Failure: View>: View {
    
    @State private var subview: Subview
    private let task: () async throws -> Value
    private let success: (Value) -> Success
    private let failure: (Error) -> Failure

    public init(
        task: @escaping () async throws -> Value,
        initial: () -> Initial,
        success: @escaping (Value) -> Success,
        failure: @escaping (Error) -> Failure
    ) {
        _subview = State(initialValue: .initial(initial()))
        self.task = task
        self.success = success
        self.failure = failure
    }

    public var body: some View {
        subview
            .task {
                do {
                    let value = try await task()
                    subview = .success(success(value))
                } catch {
                    subview = .failure(failure(error))
                }
            }
    }
}

extension AsyncView where Failure == Never {

    public init(
        task: @escaping () async -> Value,
        initial: () -> Initial,
        success: @escaping (Value) -> Success
    ) {
        self.init(
            task: task,
            initial: initial,
            success: success,
            failure: { fatalError($0.localizedDescription) }
        )
    }
}

// MARK: - Subview

extension AsyncView {

    fileprivate enum Subview {
        case initial(Initial)
        case success(Success)
        case failure(Failure)
    }
}

extension AsyncView.Subview: View {

    var body: some View {
        switch self {
        case let .initial(initial): ZStack { initial } // Ensures view exists
        case let .success(success): success
        case let .failure(failure): failure
        }
    }
}
