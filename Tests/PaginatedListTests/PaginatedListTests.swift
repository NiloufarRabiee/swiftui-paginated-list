import XCTest
@testable import PaginatedList

final class PaginatedListTests: XCTestCase {
    func testNegativeThresholdIsClampedToZero() {
        XCTAssertEqual(
            PaginationLogic.normalizedThreshold(-4),
            0
        )
    }

    func testPositiveThresholdIsPreserved() {
        XCTAssertEqual(
            PaginationLogic.normalizedThreshold(3),
            3
        )
    }

    func testRequestCanStartWhenMoreDataExists() {
        XCTAssertTrue(
            PaginationLogic.canStartRequest(
                hasMore: true,
                isLoading: false,
                hasActiveRequest: false
            )
        )
    }

    func testRequestDoesNotStartWhileLoading() {
        XCTAssertFalse(
            PaginationLogic.canStartRequest(
                hasMore: true,
                isLoading: true,
                hasActiveRequest: false
            )
        )
    }

    func testRequestDoesNotStartWithActiveRequest() {
        XCTAssertFalse(
            PaginationLogic.canStartRequest(
                hasMore: true,
                isLoading: false,
                hasActiveRequest: true
            )
        )
    }

    func testRequestDoesNotStartAtEndOfPagination() {
        XCTAssertFalse(
            PaginationLogic.canStartRequest(
                hasMore: false,
                isLoading: false,
                hasActiveRequest: false
            )
        )
    }

    func testLoadMoreTriggersInsideThreshold() {
        XCTAssertTrue(
            PaginationLogic.shouldRequestNextPage(
                currentIndex: 7,
                itemCount: 10,
                threshold: 2,
                hasMore: true,
                isLoading: false
            )
        )
    }

    func testLoadMoreDoesNotTriggerBeforeThreshold() {
        XCTAssertFalse(
            PaginationLogic.shouldRequestNextPage(
                currentIndex: 6,
                itemCount: 10,
                threshold: 2,
                hasMore: true,
                isLoading: false
            )
        )
    }

    func testLoadMoreDoesNotTriggerWithoutMoreData() {
        XCTAssertFalse(
            PaginationLogic.shouldRequestNextPage(
                currentIndex: 9,
                itemCount: 10,
                threshold: 2,
                hasMore: false,
                isLoading: false
            )
        )
    }

    func testLoadMoreDoesNotTriggerForInvalidIndex() {
        XCTAssertFalse(
            PaginationLogic.shouldRequestNextPage(
                currentIndex: 10,
                itemCount: 10,
                threshold: 2,
                hasMore: true,
                isLoading: false
            )
        )
    }
}
