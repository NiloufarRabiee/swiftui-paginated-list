import SwiftUI
import PaginatedList

private struct Message: Identifiable {
    let id: Int
    let title: String
}

private enum DemoError: LocalizedError {
    case temporaryFailure

    var errorDescription: String? {
        "The next page could not be loaded."
    }
}

struct RetryExample: View {
    @State private var messages = [
        Message(id: 1, title: "First message"),
        Message(id: 2, title: "Second message")
    ]

    @State private var hasMore = true
    @State private var shouldFail = true

    var body: some View {
        PaginatedList(
            items: $messages,
            hasMore: hasMore,
            threshold: 0,
            retryTitle: "Try again"
        ) {
            try await loadNextPage()
        } row: { message in
            Text(message.title)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()
        }
    }

    @MainActor
    private func loadNextPage() async throws {
        try await Task.sleep(
            for: .milliseconds(500)
        )

        if shouldFail {
            shouldFail = false
            throw DemoError.temporaryFailure
        }

        messages.append(
            Message(
                id: 3,
                title: "Loaded after retry"
            )
        )

        hasMore = false
    }
}
