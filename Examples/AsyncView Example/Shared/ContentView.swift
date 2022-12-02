
import AsyncView
import SwiftUI

struct ContentView: View {

    private func delayed<T>(seconds: Int, _ task: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds)) {
                continuation.resume(with: Result(catching: task))
            }
        }
    }
    
    private func delayed<T>(seconds: Int, _ task: @escaping () -> T) async -> T {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds)) {
                continuation.resume(returning: task())
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            
            AsyncView(
                task: { await delayed(seconds: 2) { "Hello world" } },
                success: SuccessView.init)

            AsyncView(
                task: { await delayed(seconds: 2) { "Hello world" } },
                initial: LoadingView.init,
                success: SuccessView.init)

            AsyncView(
                task: { try await delayed(seconds: 2) { throw Failure() } },
                success: SuccessView.init,
                failure: FailureView.init)

            AsyncView(
                task: { try await delayed(seconds: 2) { throw Failure() } },
                initial: LoadingView.init,
                success: SuccessView.init,
                failure: FailureView.init)

            AsyncView {
                await delayed(seconds: 2) { Success.random }
            } initial: {
                if Bool.random() {
                    LoadingView()
                } else {
                    ProgressView()
                }
            } success: { value in
                switch value {
                case .hello: SuccessView(value: "Hello world")
                case .goodbye: SuccessView(value: "Goodbye world")
                }
            }
        }
        .padding()
    }
}

struct Failure: Error {}

enum Success {
    case hello
    case goodbye

    static var random: Self { Bool.random() ? .hello : .goodbye }
}

struct LoadingView: View {
    var body: some View {
        Text("Loading")
    }
}

struct FailureView: View {
    let error: Error
    var body: some View {
        VStack(spacing: 10) {
            Label("Failure", systemImage: "xmark.circle")
                .font(.title)
            Text(error.localizedDescription)
        }
        .padding()
        .foregroundColor(.white)
        .background(.red)
        .cornerRadius(10)
    }
}

struct SuccessView: View {
    let value: String
    var body: some View {
        VStack(spacing: 10) {
            Label("Success", systemImage: "checkmark.circle")
                .font(.title)
            Text(value)
        }
        .padding()
        .foregroundColor(.black)
        .background(.green)
        .cornerRadius(10)
    }
}
