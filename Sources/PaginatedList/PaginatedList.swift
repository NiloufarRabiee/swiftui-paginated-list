import SwiftUI

public struct PaginatedList<
    Item: Identifiable,
    RowContent: View,
    EmptyContent: View
>: View {
    @Binding private var items: [Item]

    private let hasMore: Bool
    private let threshold: Int
    private let initialLoad: Bool
    private let rowSpacing: CGFloat
    private let retryTitle: String
    private let loadNextPage: () async throws -> Void
    private let rowContent: (Item) -> RowContent
    private let emptyContent: () -> EmptyContent

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var activeRequestID: UUID?
    @State private var loadTask: Task<Void, Never>?

    public init(
        items: Binding<[Item]>,
        hasMore: Bool,
        threshold: Int = 3,
        initialLoad: Bool = true,
        rowSpacing: CGFloat = 12,
        retryTitle: String = "Retry",
        loadNextPage: @escaping () async throws -> Void,
        @ViewBuilder row: @escaping (Item) -> RowContent,
        @ViewBuilder emptyContent: @escaping () -> EmptyContent
    ) {
        _items = items
        self.hasMore = hasMore
        self.threshold = PaginationLogic.normalizedThreshold(threshold)
        self.initialLoad = initialLoad
        self.rowSpacing = max(rowSpacing, 0)
        self.retryTitle = retryTitle
        self.loadNextPage = loadNextPage
        self.rowContent = row
        self.emptyContent = emptyContent
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: rowSpacing) {
                if items.isEmpty {
                    emptyState
                } else {
                    rows
                    footer
                }
            }
        }
        .onAppear {
            if initialLoad && items.isEmpty {
                scheduleLoad()
            }
        }
        .onDisappear {
            cancelLoad()
        }
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(items.indices, id: \.self) { index in
            rowContent(items[index])
                .onAppear {
                    if PaginationLogic.shouldRequestNextPage(
                        currentIndex: index,
                        itemCount: items.count,
                        threshold: threshold,
                        hasMore: hasMore,
                        isLoading: isLoading
                    ) {
                        scheduleLoad()
                    }
                }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if isLoading {
            ProgressView()
                .padding(.vertical, 32)
                .accessibilityLabel("Loading")
        } else if let errorMessage {
            retryView(message: errorMessage)
                .padding(.vertical, 24)
        } else {
            emptyContent()
                .padding(.vertical, 24)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if isLoading {
            ProgressView()
                .padding(.vertical, 12)
                .accessibilityLabel("Loading more")
        } else if let errorMessage {
            retryView(message: errorMessage)
                .padding(.vertical, 12)
        } else if hasMore {
            Color.clear
                .frame(height: 1)
                .id(items.count)
                .onAppear {
                    scheduleLoad()
                }
                .accessibilityHidden(true)
        }
    }

    private func retryView(message: String) -> some View {
        VStack(spacing: 8) {
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(retryTitle) {
                scheduleLoad()
            }
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private func scheduleLoad() {
        guard PaginationLogic.canStartRequest(
            hasMore: hasMore,
            isLoading: isLoading,
            hasActiveRequest: activeRequestID != nil
        ) else {
            return
        }

        let requestID = UUID()

        activeRequestID = requestID
        isLoading = true
        errorMessage = nil

        loadTask = Task {
            do {
                try await loadNextPage()

                guard !Task.isCancelled else {
                    finishRequest(
                        requestID,
                        errorMessage: nil
                    )
                    return
                }

                finishRequest(
                    requestID,
                    errorMessage: nil
                )
            } catch is CancellationError {
                finishRequest(
                    requestID,
                    errorMessage: nil
                )
            } catch {
                finishRequest(
                    requestID,
                    errorMessage: error.localizedDescription
                )
            }
        }
    }

    @MainActor
    private func finishRequest(
        _ requestID: UUID,
        errorMessage: String?
    ) {
        guard activeRequestID == requestID else {
            return
        }

        self.errorMessage = errorMessage
        isLoading = false
        activeRequestID = nil
        loadTask = nil
    }

    @MainActor
    private func cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
        activeRequestID = nil
        isLoading = false
    }
}

public extension PaginatedList where EmptyContent == Text {
    init(
        items: Binding<[Item]>,
        hasMore: Bool,
        threshold: Int = 3,
        initialLoad: Bool = true,
        rowSpacing: CGFloat = 12,
        retryTitle: String = "Retry",
        emptyTitle: String = "No items",
        loadNextPage: @escaping () async throws -> Void,
        @ViewBuilder row: @escaping (Item) -> RowContent
    ) {
        self.init(
            items: items,
            hasMore: hasMore,
            threshold: threshold,
            initialLoad: initialLoad,
            rowSpacing: rowSpacing,
            retryTitle: retryTitle,
            loadNextPage: loadNextPage,
            row: row,
            emptyContent: {
                Text(emptyTitle)
            }
        )
    }
}

enum PaginationLogic {
    static func normalizedThreshold(_ threshold: Int) -> Int {
        max(threshold, 0)
    }

    static func canStartRequest(
        hasMore: Bool,
        isLoading: Bool,
        hasActiveRequest: Bool
    ) -> Bool {
        hasMore && !isLoading && !hasActiveRequest
    }

    static func shouldRequestNextPage(
        currentIndex: Int,
        itemCount: Int,
        threshold: Int,
        hasMore: Bool,
        isLoading: Bool
    ) -> Bool {
        guard hasMore, !isLoading else {
            return false
        }

        guard itemCount > 0 else {
            return false
        }

        guard currentIndex >= 0, currentIndex < itemCount else {
            return false
        }

        let normalizedThreshold = normalizedThreshold(threshold)
        let triggerIndex = max(
            itemCount - 1 - normalizedThreshold,
            0
        )

        return currentIndex >= triggerIndex
    }
}
