//
//  ApiKeyManagerTests.swift
//  News Reader
//
//  Created by Shanmuganathan on 17/12/24.
//


import XCTest
@testable import News_Reader
class ApiKeyManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset the configReader to a mock reader before each test
        let mockReader = MockConfigReader(mockValues: [
            "API_KEY_ONE": "test_api_key_1",
            "API_KEY_TWO": "test_api_key_2"
        ])
        ApiKeyManager.shared.setConfigReader(mockReader)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetApiKey_SuccessForMultipleKeys() {
        // Act
        let keyOne = ApiKeyManager.shared.getApiKey(for: "API_KEY_ONE")
        let keyTwo = ApiKeyManager.shared.getApiKey(for: "API_KEY_TWO")

        // Assert
        XCTAssertEqual(keyOne, "test_api_key_1", "API_KEY_ONE should match")
        XCTAssertEqual(keyTwo, "test_api_key_2", "API_KEY_TWO should match")
    }

    func testGetApiKey_KeyNotFound() {
        // Act
        let result = ApiKeyManager.shared.getApiKey(for: "NON_EXISTENT_KEY")

        // Assert
        XCTAssertNil(result, "API key should be nil when the key is not found")
    }
}
