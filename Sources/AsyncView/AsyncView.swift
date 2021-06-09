import SwiftUI

@available(iOS 15.0, *)
public struct AsyncView<Value, Initial, Success, Failure>: View
where
Initial: View,
Success: View,
Failure: View
{
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

@available(iOS 15.0, *)
extension AsyncView {

    fileprivate enum Subview {
        case initial(Initial)
        case success(Success)
        case failure(Failure)
    }
}

@available(iOS 15.0, *)
extension AsyncView.Subview: View {

    var body: some View {
        switch self {
        case let .initial(initial): initial
        case let .success(success): success
        case let .failure(failure): failure
        }
    }
}
