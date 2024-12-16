//
//  MockOpenAIAPIManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

@testable import News_Reader
import Foundation

class MockOpenAIAPIManager: OpenAIAPIManager {
    var lastURL: String?
    var mockSummary: String?
    var shouldFail = false

    override func summarizeURL(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        lastURL = url
        if shouldFail {
            completion(.failure(NSError(domain: "MockError", code: 500, userInfo: nil)))
        } else {
            completion(.success(mockSummary ?? ""))
        }
    }
}
