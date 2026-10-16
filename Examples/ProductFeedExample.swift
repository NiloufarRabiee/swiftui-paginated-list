import SwiftUI
import PaginatedList

private struct Product: Identifiable {
    let id: Int
    let name: String
}

struct ProductFeedExample: View {
    @State private var products: [Product] = []
    @State private var nextPage = 1
    @State private var hasMore = true

    var body: some View {
        PaginatedList(
            items: $products,
            hasMore: hasMore,
            threshold: 2
        ) {
            try await loadNextPage()
        } row: { product in
            HStack {
                Text(product.name)
                Spacer()
                Text("#\(product.id)")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    @MainActor
    private func loadNextPage() async throws {
        try await Task.sleep(
            for: .milliseconds(650)
        )

        let start = (nextPage - 1) * 12 + 1
        let newProducts = (start..<(start + 12)).map {
            Product(
                id: $0,
                name: "Product \($0)"
            )
        }

        products.append(contentsOf: newProducts)
        nextPage += 1

        if nextPage > 4 {
            hasMore = false
        }
    }
}
