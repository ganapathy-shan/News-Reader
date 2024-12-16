//
//  MetaData.swift
//  News Reader
//
//  Created by Shanmuganathan on 07/11/24.
//


// MetaData Model for pagination
struct MetaData: Codable {
    let found: Int
    let returned: Int
    let limit: Int
    let page: Int
}
