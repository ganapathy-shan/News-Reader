//
//  ContentSynthesizer.swift
//  News Reader
//
//  Created by Shanmuganathan on 16/12/24.
//

import Foundation
import UIKit

class ContentSynthesizer {
    private let summarizationManager: SummarizationManagerProtocol
    private let speechSynthesizer: SpeechSynthesizerProtocol

    init(summarizationManager: SummarizationManagerProtocol = FoundationModelSummarizer.shared,
         speechSynthesizer: SpeechSynthesizerProtocol = AppleSpeechSynthesizer.shared) {
        self.summarizationManager = summarizationManager
        self.speechSynthesizer = speechSynthesizer
    }

    func synthesizeContent(from urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }

        summarizationManager.summarizeURL(url: urlString) { result in
            switch result {
            case .success(let summary):
                self.speechSynthesizer.synthesizeSpeech(from: summary) { synthesisResult in
                    completion(synthesisResult)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
