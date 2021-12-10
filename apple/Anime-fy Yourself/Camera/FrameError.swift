//
//  FrameError.swift
//  Anime-fy Yourself
//
//  Created by Yonatan Mittlefehldt on 2021-12-07.
//

import Foundation

enum FrameError: Error {
    case tooFewSamples
    case tooManySamples
}

extension FrameError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .tooFewSamples:
            return "No samples received"
        case .tooManySamples:
            return "Multiple samples received simultaneously"
        }
    }
}
