
import AsyncView
import SwiftUI

struct TaskView: View {

    let title: String
    let image: String
    let foreground: Color
    let background: Color
    let task: () async throws -> String

    var body: some View {

        VStack(spacing: 10) {
            Label(title, systemImage: image)
                .font(.title)
            AsyncView {
                try await task()
            } initial: {
                ProgressView()
            } success: { value in
                Text("\(value)")
            } failure: { error in
                Text(error.localizedDescription)
            }
        }
        .padding()
        .progressViewStyle(CircularProgressViewStyle(tint: foreground))
        .foregroundColor(foreground)
        .background(background)
        .cornerRadius(10)
    }
}

struct Failure: Error {}

struct ContentView: View {

    private func delayed<T>(seconds: Int, _ task: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds)) {
                continuation.resume(with: Result(catching: task))
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {

            TaskView(title: "Success", image: "checkmark.circle", foreground: .black, background: .green) {
                try await delayed(seconds: 2) { "Hello world" }
            }

            TaskView(title: "Failure", image: "xmark.circle", foreground: .white, background: .red) {
                try await delayed(seconds: 3) { throw Failure() }
            }
        }
        .padding()
    }
}
