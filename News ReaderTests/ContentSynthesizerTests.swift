//
//  ContentSynthesizerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//


import XCTest
@testable import News_Reader

class ContentSynthesizerTests: XCTestCase {
    func testSynthesizeContent_withValidURL_callsAPIAndSynthesizer() {
        // Arrange
        let mockAPIManager = MockOpenAIAPIManager()
        let mockSpeechSynthesizer = MockSpeechSynthesizer()
        
        let contentSynthesizer = ContentSynthesizer(apiManager: mockAPIManager, speechSynthesizer: mockSpeechSynthesizer)

        let urlString = "https://example.com"
        let summary = "Mock summary"
        mockAPIManager.mockSummary = summary

        let expectation = XCTestExpectation(description: "Synthesis completes successfully")

        // Act
        contentSynthesizer.synthesizeContent(from: urlString) { result in
            switch result {
            case .success:
                XCTAssertEqual(mockAPIManager.lastURL, urlString, "API Manager should be called with the correct URL")
                XCTAssertEqual(mockSpeechSynthesizer.lastSynthesizedText, summary, "Speech Synthesizer should be called with the correct summary")
                expectation.fulfill()
            case .failure:
                XCTFail("Synthesis should succeed for valid URL and mock data")
            }
        }

        // Assert
        wait(for: [expectation], timeout: 5.0)
    }

    func testSynthesizeContent_withInvalidURL_returnsError() {
        // Arrange
        let contentSynthesizer = ContentSynthesizer()
        let invalidURLString = "InvalidURL"

        let expectation = XCTestExpectation(description: "Error should be returned for invalid URL")

        // Act
        contentSynthesizer.synthesizeContent(from: invalidURLString) { result in
            switch result {
            case .success:
                XCTFail("Synthesis should fail for invalid URL")
            case .failure(let error):
                XCTAssertEqual((error as NSError).domain, "InvalidURL", "Error should indicate invalid URL")
                expectation.fulfill()
            }
        }

        // Assert
        wait(for: [expectation], timeout: 5.0)
    }
}
