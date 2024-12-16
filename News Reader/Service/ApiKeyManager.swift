//
//  ApiKeyManager.swift
//  News Reader
//
//  Created by Shanmuganathan on 17/12/24.
//


import Foundation

// MARK: - ApiKeyManager
class ApiKeyManager {
    static let shared = ApiKeyManager()
    private var configReader: ConfigReader

    // Dependency injection for testability
    private init(configReader: ConfigReader = PlistConfigReader()) {
        self.configReader = configReader
    }

    /// Retrieves the API key for the given key name.
    /// - Parameter keyName: The key name in the Config file.
    /// - Returns: The API key as a String or nil if not found.
    func getApiKey(for keyName: String) -> String? {
        return configReader.readConfigValue(forKey: keyName)
    }

    // MARK: - Test Helper (DEBUG only)
    #if DEBUG
    func setConfigReader(_ reader: ConfigReader) {
        self.configReader = reader
    }
    #endif
}

