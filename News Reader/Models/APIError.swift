//
//  APIError.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//

// APIError.swift
struct APIError: Decodable, Error {
    let code: String
    let message: String

    enum CodingKeys: String, CodingKey {
        case error
    }

    enum ErrorKeys: String, CodingKey {
        case code
        case message
    }

    // Custom initializer to handle nested "error" JSON structure
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: ErrorKeys.self, forKey: .error)
        self.code = try errorContainer.decode(String.self, forKey: .code)
        self.message = try errorContainer.decode(String.self, forKey: .message)
    }

    // New initializer to support throwing with a custom message
    init(message: String) {
        self.code = "Unknown"
        self.message = message
    }
}
