//
//  SpeechSynthesizer.swift
//  News Reader
//
//  Created by Shanmuganathan on 14/12/24.
//


import Foundation
import AVFoundation
import AWSPolly

protocol SpeechSynthesizerProtocol {
    func synthesizeSpeech(from text: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class SpeechSynthesizer : SpeechSynthesizerProtocol {
    private var audioPlayer: AVPlayer?

    static let shared = SpeechSynthesizer()
    var identityPoolId : String = ""

    private init() {
        
           if let poolId = ApiKeyManager.shared.getApiKey(for: "AWSPoolID") {
               identityPoolId = poolId
           }
        
           // Manually configure AWS credentials and region
           let credentialsProvider = AWSCognitoCredentialsProvider(
               regionType: .USWest2, // Set your AWS region (example: us-west-2)
               identityPoolId: identityPoolId
           )

           let configuration = AWSServiceConfiguration(
               region: .USWest2, // Set your Polly region (example: us-west-2)
               credentialsProvider: credentialsProvider
           )

           AWSServiceManager.default().defaultServiceConfiguration = configuration
       }

    /// Synthesize and play speech for the given text
    /// - Parameters:
    ///   - text: The text to be converted to speech
    ///   - completion: A closure that handles success or failure
    func synthesizeSpeech(from text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if !identityPoolId.isEmpty {
            let input = AWSPollySynthesizeSpeechURLBuilderRequest()
            // Use SSML for better prosody control
            input.text = """
            <speak>
            <amazon:domain name="news">
            \(text)
            </amazon:domain>
            </speak>
            """
            input.outputFormat = .mp3
            input.voiceId = .amy
            input.textType = .ssml
            input.engine = .neural
            
            let builder = AWSPollySynthesizeSpeechURLBuilder.default().getPreSignedURL(input)
            
            builder.continueWith { [weak self] task -> Any? in
                if let url = task.result {
                    DispatchQueue.main.async {
                        self?.audioPlayer = AVPlayer(url: url as URL)
                        self?.audioPlayer?.playImmediately(atRate: 1.0)
                        completion(.success(()))
                    }
                } else if let error = task.error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return nil
            }
        } else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
        }
    }
}
