//
//  WebContentExtractorTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

@testable import News_Reader
import XCTest

final class WebContentExtractorTests: XCTestCase {
    var extractor: MockWebContentExtractor!

    override func setUp() {
        super.setUp()
        extractor = MockWebContentExtractor()
    }

    func testFetchContentSuccess() {
        extractor.shouldSucceed = true
        extractor.mockContent = "Mock content"

        let expectation = self.expectation(description: "Content fetch should succeed")

        extractor.fetchContent(from: "https://example.com") { result in
            switch result {
            case .success(let content):
                XCTAssertEqual(content, "Mock content", "Fetched content should match mock content.")
                expectation.fulfill()
            case .failure:
                XCTFail("Content fetch should not fail.")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchContentFailure() {
        extractor.shouldSucceed = false
        extractor.mockError = NSError(domain: "MockWebContentExtractor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])

        let expectation = self.expectation(description: "Content fetch should fail")

        extractor.fetchContent(from: "https://example.com") { result in
            switch result {
            case .success:
                XCTFail("Content fetch should fail.")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Mock error", "Error should match the mock error.")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0)
    }
}
