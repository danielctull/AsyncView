
import AsyncView
import SwiftUI

struct ContentView: View {
    var body: some View {
        AsyncView {
            "Hello world"
        } initial: {
            ProgressView()
        } success: { value in
            Text("\(value)")
        } failure: { error in
            Text(error.localizedDescription)
        }
    }
}
