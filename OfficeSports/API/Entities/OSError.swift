//
//  OSError.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

enum OSError: LocalizedError {
    
    case unauthorized
    
    case missingToken
    
    case nicknameTaken
    
    case missingPlayer
    
    case invalidQrCode
    
    case invalidOpponent
    
    case nicknameMissing
    
    case nicknameTooShort
    
    case nicknameTooLong
    
    case invalidInvite
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized"
        case .missingToken:
            return "Missing ID token"
        case .nicknameTaken:
            return "Nickname already taken"
        case .missingPlayer:
            return "Unauthorized. Missing player details"
        case .invalidQrCode:
            return "The QR code is not valid"
        case .invalidOpponent:
            return "You cannot play against yourself dumbass!"
        case .nicknameMissing:
            return "Nickname is missing"
        case .nicknameTooShort:
            return "Nickname is too short"
        case .nicknameTooLong:
            return "Nickname is too long"
        case .invalidInvite:
            return "You cannot invite yourself dumbass!"
        }
    }
}
