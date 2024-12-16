//
//  WebContentExtractor.swift
//  News Reader
//
//  Created by Shanmuganathan on 14/12/24.
//


import Foundation

protocol WebContentExtractorProtocol {
    func fetchContent(from url: String, completion: @escaping (Result<String, Error>) -> Void)
}

class WebContentExtractor : WebContentExtractorProtocol {
    static let shared = WebContentExtractor()

    private init() {}

    // Fetch and parse content from URL
    func fetchContent(from url: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "WebContentExtractor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "WebContentExtractor", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            guard let htmlString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "WebContentExtractor", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to decode HTML"])))
                return
            }

            // Extract content from HTML
            if let content = self.extractMainContent(from: htmlString) {
                completion(.success(content))
            } else {
                completion(.failure(NSError(domain: "WebContentExtractor", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to extract content"])))
            }
        }
        task.resume()
    }

    // Simple HTML parser to extract text content (improve this as needed)
    private func extractMainContent(from html: String) -> String? {
        // Remove scripts, styles, and other irrelevant tags
        let cleanedHTML = html.replacingOccurrences(of: "<script[^>]*>[\\s\\S]*?</script>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<style[^>]*>[\\s\\S]*?</style>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // Extract meaningful content heuristically
        let paragraphs = cleanedHTML.components(separatedBy: "\n").filter { $0.count > 50 } // Filter long lines as content
        return paragraphs.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
