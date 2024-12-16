//
//  MockSpeechSynthesizer.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

@testable import News_Reader
import Foundation

class MockSpeechSynthesizer: SpeechSynthesizerProtocol {
    var lastSynthesizedText: String?
    var shouldFail = false

    func synthesizeSpeech(from text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        lastSynthesizedText = text
        if shouldFail {
            completion(.failure(NSError(domain: "MockError", code: 500, userInfo: nil)))
        } else {
            completion(.success(()))
        }
    }
}
