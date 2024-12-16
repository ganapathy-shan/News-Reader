//
//  SpeechSynthesizerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

import XCTest
@testable import News_Reader

final class SpeechSynthesizerTests: XCTestCase {
    func testSynthesizeSpeechSuccess() {
        let synthesizer = SpeechSynthesizer.shared
        let expectation = self.expectation(description: "Speech synthesis should complete successfully")

        synthesizer.synthesizeSpeech(from: "Hello, world!") { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Speech synthesis should not fail.")
            }
        }

        waitForExpectations(timeout: 5.0)
    }
}
