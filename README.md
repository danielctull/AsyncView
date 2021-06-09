# AsyncView

[![Latest release][release shield]][releases] [![Swift 5.5][swift shield]][swift] ![Platforms: iOS, macOS, tvOS, watchOS][platforms shield]

A SwiftUI view that performs an async task when appearing and allows the caller show different views based on the success and failure cases.

## Usage

This can be used with an async function that fetches some data and decodes it into a model. In the following example, we display a list of posts when they are received or show the error message if the call to `fetchPosts` fails.

```swift
struct Post: Identifiable {
    let id: String
    let title: String
}

struct PostsView: View {

    private func fetchPosts() async throws -> [Post] {
        return [] // Actually implement network call!
    }

    var body: some View {
        AsyncView {
            try await fetchPosts()
        } initial: {
            ProgressView()
        } success: { posts in
            Success(posts: posts)
        } failure: { error in
            Failure(error: error)
        }
    }

    struct Success: View {
        let posts: [Post]
        var body: some View {
            List(posts) { post in
                Text(post.title)
            }
        }
    }

    struct Failure: View {
        let error: Error
        var body: some View {
            Text(error.localizedDescription)
        }
    }
}
```

[releases]: https://github.com/danielctull/PublisherView/releases
[release shield]: https://img.shields.io/github/v/release/danielctull/AsyncView
[swift]: https://swift.org
[swift shield]: https://img.shields.io/badge/swift-5.5-F05138.svg "Swift 5.5"
[platforms shield]: https://img.shields.io/badge/platforms-iOS_macOS_tvOS_watchOS-lightgrey.svg?style=flat "iOS, macOS, tvOS, watchOS"
