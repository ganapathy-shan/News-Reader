//
//  MockWebContentExtractor.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

@testable import News_Reader
import Foundation

class MockWebContentExtractor: WebContentExtractorProtocol {
    var shouldSucceed = true
    var mockContent = "Mock article content."
    var mockError: Error = NSError(domain: "MockWebContentExtractor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])

    func fetchContent(from url: String, completion: @escaping (Result<String, Error>) -> Void) {
        if shouldSucceed {
            completion(.success(mockContent))
        } else {
            completion(.failure(mockError))
        }
    }
}
