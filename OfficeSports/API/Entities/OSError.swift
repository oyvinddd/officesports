//
//  OSError.swift
//  Office Sports
//
//  Created by Γyvind Hauge on 23/05/2022.
//

import Foundation

enum OSError: LocalizedError {
    
    case unknown
    
    case unauthorized
    
    case missingToken
    
    case nicknameTaken
    
    case missingPlayer
    
    case invalidQrCode
    
    case invalidOpponent
    
    case nicknameMissing
    
    case nicknameTooShort
    
    case nicknameTooLong
    
    case invalidNickname
    
    case invalidInvite
    
    case inviteNotAllowed
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Something went wrong"
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
            return "You cannot register a match result against yourself dumbass! π€¦π»ββοΈ"
        case .nicknameMissing:
            return "Nickname is missing"
        case .nicknameTooShort:
            return "Nickname is too short"
        case .nicknameTooLong:
            return "Nickname is too long"
        case .invalidNickname:
            return "Nickname cannot contain spaces"
        case .invalidInvite:
            return "You cannot invite yourself to a match dumbass! π€¦π»ββοΈ"
        case .inviteNotAllowed:
            return "You need to wait 15 minutes between every time you invite someone to a match π"
        }
    }
}
