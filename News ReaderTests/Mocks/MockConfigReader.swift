//
//  MockConfigReader.swift
//  News Reader
//
//  Created by Shanmuganathan on 17/12/24.
//

@testable import News_Reader

class MockConfigReader: ConfigReader {
    private let mockValues: [String: String]

    init(mockValues: [String: String]) {
        self.mockValues = mockValues
    }

    func readConfigValue(forKey key: String) -> String? {
        return mockValues[key]
    }
}
