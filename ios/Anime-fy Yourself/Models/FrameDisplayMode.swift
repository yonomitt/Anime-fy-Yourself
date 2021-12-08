//
//  FrameDisplayMode.swift
//  Anime-fy Yourself
//
//  Created by Yonatan Mittlefehldt on 2021-12-08.
//

import Foundation

enum FrameDisplayMode: CaseIterable {
    case original
    case anime
    case both
    
    var shouldShowOriginal: Bool {
        self != .anime
    }
    
    var shouldShowAnime: Bool {
        self != .original
    }
    
    /// Returns the next case in the enum, cycling back to the first when the last one is reached
    /// - Returns: next case
    func next() -> FrameDisplayMode {
        guard var index = FrameDisplayMode.allCases.firstIndex(of: self) else {
            return .original
        }
        
        index += 1
        if index >= FrameDisplayMode.allCases.count {
            index = 0
        }
        
        return FrameDisplayMode.allCases[index]
    }
}
