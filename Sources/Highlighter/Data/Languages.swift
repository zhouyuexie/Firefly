//
//  Data.swift
//  Firefly
//
//  Created by Zachary lineman on 12/24/20.
//

import Foundation

struct LanguageDefinition {
    let regex: String
    let group: Int
    let relevance: Int
    let options: [NSRegularExpression.Options]
    let multiline: Bool

    static let initValue = LanguageDefinition(
        regex: "",
        group: 0,
        relevance: 0,
        options: [],
        multiline: false
    )
}

public enum Language: String {
    case basic = "Basic"
    case swift = "Swift"
}

let languages: [Language: [String: LanguageDefinition]] = [
    Language.basic: [:],
    Language.swift: swiftLanguage
]
