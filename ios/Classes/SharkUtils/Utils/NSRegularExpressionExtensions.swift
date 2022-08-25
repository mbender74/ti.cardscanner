//
//  NSRegularExpressionExtensions.swift
//  Store
//
//  Created by Dominic Campbell on 05/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import Foundation

public extension NSRegularExpression {
    func matches(in content: String) -> [NSTextCheckingResult] {
        matches(in: content, range: content.fullNSRange)
    }
    
    func stringMatches(in content: String) -> [String] {
        matches(in: content).extractStrings(from: content)
    }
}

public struct RegexHandle: ExpressibleByStringLiteral {
    public let regex: NSRegularExpression
    public init(stringLiteral value: StringLiteralType) {
        do {
            self.regex = try NSRegularExpression(pattern: value, options: .allowCommentsAndWhitespace)
        } catch {
            // Should only fail during development as all should regex have at least 1 unit test that creates it
            fatalError("\(error)")
        }
    }
}

public extension String {
    var fullNSRange: NSRange {
        NSRange(location: 0, length: count)
    }
    func string(for nsRange: NSRange) -> String? {
        Range(nsRange, in: self).flatMap {
            "\(self[$0])"
        }
    }
}

public extension Array where Element == NSTextCheckingResult {
    func extractStrings(from content: String) -> [String] {
        flatMap { result in
            (0..<result.numberOfRanges).compactMap { i in
                content.string(for: result.range(at: i))
            }
        }
    }
}
