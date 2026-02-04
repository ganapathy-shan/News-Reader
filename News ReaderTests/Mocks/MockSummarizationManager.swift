//
//  MockSummarizationManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 04/02/26.
//

@testable import News_Reader
import Foundation

class MockSummarizationManager: SummarizationManagerProtocol {
    var lastURL: String?
    var mockSummary: String?
    var shouldFail = false

    func summarizeURL(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        lastURL = url
        if shouldFail {
            completion(.failure(NSError(domain: "MockError", code: 500, userInfo: nil)))
        } else {
            completion(.success(mockSummary ?? ""))
        }
    }
}
