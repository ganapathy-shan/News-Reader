//
//  AppleSpeechSynthesizer.swift
//  News Reader
//
//  Created by Shanmuganathan on 04/02/26.
//

import AVFoundation
import Foundation

class AppleSpeechSynthesizer: SpeechSynthesizerProtocol {
    static let shared = AppleSpeechSynthesizer()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func synthesizeSpeech(from text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.failure(NSError(domain: "SpeechSynthesizer", code: 400, userInfo: [NSLocalizedDescriptionKey: "Empty text."])))
            return
        }

        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: trimmed)
            utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.identifier)
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            self.synthesizer.speak(utterance)
            completion(.success(()))
        }
    }
}
