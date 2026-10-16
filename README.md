# PaginatedList

[![CI](https://github.com/NiloufarRabiee/swiftui-paginated-list/actions/workflows/ci.yml/badge.svg)](https://github.com/NiloufarRabiee/swiftui-paginated-list/actions/workflows/ci.yml)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![iOS](https://img.shields.io/badge/iOS-16%2B-blue)
![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight reusable **SwiftUI paginated list with async loading, retry handling, duplicate-request prevention, and load-more states**.

## Features

- Native SwiftUI
- Initial async loading
- Automatic load-more behavior
- Configurable prefetch threshold
- Duplicate-request prevention
- Error state with retry
- Request cancellation when the view disappears
- Custom empty content
- Configurable retry label
- Configurable row spacing
- No networking dependency
- No third-party dependencies
- iOS and macOS support
- Swift Package Manager support

## Requirements

- iOS 16+
- macOS 13+
- Swift 5.9+

## Installation

### Swift Package Manager

In Xcode:

1. Open your project.
2. Go to **File > Add Package Dependencies...**
3. Enter:

```
https://github.com/NiloufarRabiee/swiftui-paginated-list
```

4. Add the `PaginatedList` package to your app target.

Then import it:

```swift
import PaginatedList
```

## Basic Usage

```swift
PaginatedList(
    items: $items,
    hasMore: hasMore
) {
    try await loadNextPage()
} row: { item in
    ProductRow(item: item)
}
```

The first page loads automatically when the list appears empty. Additional pages load as the user approaches the end.

## Prefetch Threshold

Use `threshold` to decide how early the next page should begin loading:

```swift
PaginatedList(
    items: $items,
    hasMore: hasMore,
    threshold: 3
) {
    try await loadNextPage()
} row: { item in
    Row(item: item)
}
```

A threshold of `3` starts loading when the user reaches one of the final four items.

Set it to `0` to wait until the final item appears.

## Retry Handling

If `loadNextPage` throws, the list displays the error description and a retry button.

```swift
PaginatedList(
    items: $items,
    hasMore: hasMore,
    retryTitle: "Try again"
) {
    try await api.fetchNextPage()
} row: { item in
    Row(item: item)
}
```

## Empty Content

Provide a custom empty state when needed:

```swift
PaginatedList(
    items: $items,
    hasMore: hasMore,
    loadNextPage: {
        try await loadNextPage()
    },
    row: { item in
        Row(item: item)
    },
    emptyContent: {
        VStack(spacing: 8) {
            Image(systemName: "tray")
            Text("Nothing here yet")
        }
    }
)
```

The convenience initializer uses `No items` by default.

## Disable Initial Loading

For externally loaded first pages:

```swift
PaginatedList(
    items: $items,
    hasMore: hasMore,
    initialLoad: false
) {
    try await loadNextPage()
} row: { item in
    Row(item: item)
}
```

## Duplicate-Request Prevention

The component tracks the active request and ignores new load triggers until the current request finishes.

This prevents several near-end rows from starting the same page request at the same time.

## Cancellation

An active loading task is cancelled when `PaginatedList` disappears.

The async operation supplied to `loadNextPage` should cooperate with Swift task cancellation.

## Data Ownership

`PaginatedList` does not own your data source or networking layer.

Your application controls:

- The item array
- Whether another page exists
- Page or cursor state
- Network requests
- Decoding and persistence

The component only manages when another page should be requested and how the loading state is presented.

## Examples

Two examples are included:

```
Examples/ProductFeedExample.swift
Examples/RetryExample.swift
```

## Testing

The package includes unit tests for:

- Threshold normalization
- Request gating
- Duplicate-request prevention
- End-of-pagination behavior
- Near-end prefetching
- Invalid indexes

Run:

```bash
swift test
```

## Contributing

Contributions and improvements are welcome.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is available under the MIT License.

See [LICENSE](LICENSE).

---

Created by **Niloufar Rabiee**
