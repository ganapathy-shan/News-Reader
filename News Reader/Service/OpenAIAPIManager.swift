//
//  OpenAIAPIManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 14/12/24.
//


import Foundation

protocol OpenAIAPIManagerProtocol {
    func summarizeURL(url: String, completion: @escaping (Result<String, Error>) -> Void)
}

class OpenAIAPIManager : OpenAIAPIManagerProtocol {
    static let shared = OpenAIAPIManager()
    private var openAIAPIKey = ""

    private var webContentExtractor: WebContentExtractorProtocol
    private var summaryCacheManager: SummaryCacheManagerProtocol
    private let session: URLSessionProtocol

    init(webContentExtractor: WebContentExtractorProtocol = WebContentExtractor.shared,
         summaryCacheManager: SummaryCacheManagerProtocol = SummaryCacheManager.shared,
         session: URLSessionProtocol = URLSession.shared) {
        self.webContentExtractor = webContentExtractor
        self.summaryCacheManager = summaryCacheManager
        self.session = session
        if let apiKey = ApiKeyManager.shared.getApiKey(for: "OpenAPIKey") {
            openAIAPIKey = apiKey
        }
    }

    // Fetch and summarize content from URL
    func summarizeURL(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.webContentExtractor.fetchContent(from: url) { [weak self] result in
            switch result {
            case .success(let content):
                self?.summarize(text: content, url: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func summarize(text: String, url: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if the summary is already cached
        if let cachedSummary = self.summaryCacheManager.getCachedSummary(forURL: url) {
            completion(.success(cachedSummary))
            return
        }
        
        guard !openAIAPIKey.isEmpty else {
            completion(.failure(NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API Key"])))
            return
        }
        

        // If not cached, fetch from OpenAI
        guard let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(.failure(NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo", // Or "gpt-4"
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that summarizes articles into concise and engaging narratives for a news reader application."
                ],
                [
                    "role": "user",
                    "content": """
        Summarize the following article into a concise and engaging narrative suitable for a news reader application. Ensure the summary flows naturally, retains the key details, and uses a tone that sounds professional yet conversational. Avoid technical jargon unless necessary and prioritize readability and coherence.

        ### Article Content:
        \(text)

        ### Requirements for the Summary:
        1. Start with a captivating lead sentence that summarizes the main point.
        2. Provide a clear and engaging summary of the article’s key details.
        3. Conclude with relevant context or implications if applicable.
        4. Keep the summary under 200 words.
        """
                ]
            ],
            "max_tokens": 200,
            "temperature": 0.7
        ]


        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "OpenAI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])))
            return
        }

        var request = URLRequest(url: openAIURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAI", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            // Log the raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let summary = message["content"] as? String {
                        // Cache the summary
                        self.summaryCacheManager.cacheSummary(summary, forURL: url)
                        completion(.success(summary.trimmingCharacters(in: .whitespacesAndNewlines)))
                    } else {
                        let errorInfo = json["error"] as? [String: Any]
                        let message = errorInfo?["message"] as? String ?? "Unknown error"
                        completion(.failure(NSError(domain: "OpenAI", code: -4, userInfo: [NSLocalizedDescriptionKey: message])))
                    }
                } else {
                    completion(.failure(NSError(domain: "OpenAI", code: -5, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
