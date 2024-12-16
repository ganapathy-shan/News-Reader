//
//  ConfigReader.swift
//  News Reader
//
//  Created by Shanmuganathan on 17/12/24.
//


import Foundation

// MARK: - Protocol for ConfigReader
protocol ConfigReader {
    func readConfigValue(forKey key: String) -> String?
}

// MARK: - PlistConfigReader Implementation
class PlistConfigReader: ConfigReader {
    private let fileName: String

    init(fileName: String = "config") {
        self.fileName = fileName
    }

    func readConfigValue(forKey key: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            return nil
        }
        return plist[key] as? String
    }
}
