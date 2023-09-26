import SwiftUI

public struct AsyncView<ID: Equatable, Value, Initial: View, Success: View, Failure: View>: View {

    @State private var subview: Subview
    private let id: ID
    private let task: (ID) async throws -> Value
    private let success: (Value) -> Success
    private let failure: (Error) -> Failure

    public init(
        id: ID,
        task: @escaping (ID) async throws -> Value,
        @ViewBuilder initial: () -> Initial,
        @ViewBuilder success: @escaping (Value) -> Success,
        @ViewBuilder failure: @escaping (Error) -> Failure
    ) {
        _subview = State(initialValue: .initial(initial()))
        self.id = id
        self.task = task
        self.success = success
        self.failure = failure
    }

    public var body: some View {
        subview
            .task(id: id) {
                do {
                    let value = try await task(id)
                    subview = .success(success(value))
                } catch {
                    subview = .failure(failure(error))
                }
            }
    }
}

extension AsyncView where Failure == Never {

    public init(
        id: ID,
        task: @escaping (ID) async -> Value,
        @ViewBuilder initial: () -> Initial,
        @ViewBuilder success: @escaping (Value) -> Success
    ) {
        self.init(
            id: id,
            task: task,
            initial: initial,
            success: success,
            failure: { fatalError($0.localizedDescription) }
        )
    }
}

// MARK: - EmptyView

extension AsyncView where Initial == EmptyView {

    public init(
        id: ID,
        task: @escaping (ID) async throws -> Value,
        @ViewBuilder success: @escaping (Value) -> Success,
        @ViewBuilder failure: @escaping (Error) -> Failure
    ) {
        self.init(
            id: id,
            task: task,
            initial: EmptyView.init,
            success: success,
            failure: failure
        )
    }
}

extension AsyncView where Initial == EmptyView, Failure == Never {

    public init(
        id: ID,
        task: @escaping (ID) async -> Value,
        @ViewBuilder success: @escaping (Value) -> Success
    ) {
        self.init(
            id: id,
            task: task,
            initial: EmptyView.init,
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
        case let .initial(initial) where initial is EmptyView:
            ZStack { initial } // Ensures view exists as task won't start on EmptyView.
        case let .initial(initial): initial
        case let .success(success): success
        case let .failure(failure): failure
        }
    }
}

// MARK: - No ID

public struct NoID: Equatable {}

extension AsyncView where ID == NoID {
    public init(
        task: @escaping () async throws -> Value,
        @ViewBuilder initial: () -> Initial,
        @ViewBuilder success: @escaping (Value) -> Success,
        @ViewBuilder failure: @escaping (Error) -> Failure
    ) {

        self.init(
            id: NoID(),
            task: { _ in try await task() },
            initial: initial,
            success: success,
            failure: failure)
    }
}

extension AsyncView where ID == NoID, Failure == Never {

    public init(
        task: @escaping () async -> Value,
        @ViewBuilder initial: () -> Initial,
        @ViewBuilder success: @escaping (Value) -> Success
    ) {
        self.init(
            task: task,
            initial: initial,
            success: success,
            failure: { fatalError($0.localizedDescription) }
        )
    }
}

extension AsyncView where ID == NoID, Initial == EmptyView {

    public init(
        task: @escaping () async throws -> Value,
        @ViewBuilder success: @escaping (Value) -> Success,
        @ViewBuilder failure: @escaping (Error) -> Failure
    ) {
        self.init(
            task: task,
            initial: EmptyView.init,
            success: success,
            failure: failure
        )
    }
}

extension AsyncView where ID == NoID, Initial == EmptyView, Failure == Never {

    public init(
        task: @escaping () async -> Value,
        @ViewBuilder success: @escaping (Value) -> Success
    ) {
        self.init(
            task: task,
            initial: EmptyView.init,
            success: success,
            failure: { fatalError($0.localizedDescription) }
        )
    }
}
