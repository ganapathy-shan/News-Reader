//
//  FoundationModelSummarizer.swift
//  News Reader
//
//  Created by Shanmuganathan on 04/02/26.
//

import Foundation
import FoundationModels

protocol SummarizationManagerProtocol {
    func summarizeURL(url: String, completion: @escaping (Result<String, Error>) -> Void)
}

protocol SummaryGeneratorProtocol {
    func generateSummary(from text: String) async throws -> String
}

enum SummarizationError: LocalizedError {
    case emptyContent
    case foundationModelsUnavailable
    case modelUnavailable(reason: String)

    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "No content available to summarize."
        case .foundationModelsUnavailable:
            return "Apple Foundation Models are not available on this device."
        case .modelUnavailable(let reason):
            return "Apple Foundation Models are unavailable: \(reason)."
        }
    }
}

class FoundationModelSummarizer: SummarizationManagerProtocol {
    static let shared = FoundationModelSummarizer()

    private let webContentExtractor: WebContentExtractorProtocol
    private let summaryCacheManager: SummaryCacheManagerProtocol
    private let summaryGenerator: SummaryGeneratorProtocol

    init(webContentExtractor: WebContentExtractorProtocol = WebContentExtractor.shared,
         summaryCacheManager: SummaryCacheManagerProtocol = SummaryCacheManager.shared,
         summaryGenerator: SummaryGeneratorProtocol? = nil) {
        self.webContentExtractor = webContentExtractor
        self.summaryCacheManager = summaryCacheManager
        if let summaryGenerator = summaryGenerator {
            self.summaryGenerator = summaryGenerator
        } else if #available(iOS 26.0, *) {
            self.summaryGenerator = FoundationModelsSummaryGenerator()
        } else {
            self.summaryGenerator = UnavailableSummaryGenerator()
        }
    }

    // Fetch and summarize content from URL
    func summarizeURL(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let cachedSummary = summaryCacheManager.getCachedSummary(forURL: url) {
            completion(.success(cachedSummary))
            return
        }

        webContentExtractor.fetchContent(from: url) { [weak self] result in
            switch result {
            case .success(let content):
                self?.summarize(text: content, url: url, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func summarize(text: String, url: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let cachedSummary = summaryCacheManager.getCachedSummary(forURL: url) {
            completion(.success(cachedSummary))
            return
        }

        Task {
            do {
                let summary = try await summaryGenerator.generateSummary(from: text)
                summaryCacheManager.cacheSummary(summary, forURL: url)
                completion(.success(summary))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private struct UnavailableSummaryGenerator: SummaryGeneratorProtocol {
    func generateSummary(from text: String) async throws -> String {
        throw SummarizationError.foundationModelsUnavailable
    }
}

@available(iOS 26.0, *)
private struct FoundationModelsSummaryGenerator: SummaryGeneratorProtocol {
    @MainActor
    func generateSummary(from text: String) async throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SummarizationError.emptyContent
        }

        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            break
        case .unavailable(let reason):
            throw SummarizationError.modelUnavailable(reason: String(describing: reason))
        }

        let session = LanguageModelSession(model: model)
        let prompt = """
        You are a helpful assistant that summarizes articles into concise and engaging narratives for a news reader application.

        Summarize the following article into a concise and engaging narrative suitable for a news reader application. Ensure the summary flows naturally, retains the key details, and uses a tone that sounds professional yet conversational. Avoid technical jargon unless necessary and prioritize readability and coherence.

        ### Article Content:
        \(trimmed)

        ### Requirements for the Summary:
        1. Start with a captivating lead sentence that summarizes the main point.
        2. Provide a clear and engaging summary of the article’s key details.
        3. Conclude with relevant context or implications if applicable.
        4. Keep the summary under 200 words.
        """

        let options = GenerationOptions(temperature: 0.7, maximumResponseTokens: 200)
        let response = try await session.respond(to: prompt, options: options)
        return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
