//
//  EmojiViewModel.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 21/05/2022.
//

import Foundation

protocol EmojiViewModelDelegate: AnyObject {
    
}

final class EmojiViewModel {
    
    var emojis: [String] = loadEmojisFromFile(filename: "emojis")
    
    private static func loadEmojisFromFile(filename: String) -> [String] {
        var emojis = [String]()
        if let filePath = Bundle.main.path(forResource: filename, ofType: "csv") {
            do {
                let contents = try String(contentsOfFile: filePath)
                emojis = contents.components(separatedBy: ",")
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Emoji file not found")
        }
        return emojis
    }
}
