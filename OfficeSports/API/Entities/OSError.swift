//
//  OSError.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 23/05/2022.
//

import Foundation

struct OSError: LocalizedError, Decodable {
    
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    static let unknown = OSError("Something went wrong")
    
    static let unauthorized = OSError("Unauthorized")
    
    static let missingToken = OSError("Missing ID token")
    
    static let nicknameTaken = OSError("Nickname already taken")
    
    static let missingPlayer = OSError("Unauthorized. Missing player details.")
    
    static let invalidQrCode = OSError("The QR code is not valid")
    
    static let invalidOpponent = OSError("You cannot register a match result against yourself dumbass! 🤦🏻‍♂️")
    
    static let nicknameMissing = OSError("Nickname is missing")
    
    static let nicknameTooShort = OSError("Nickname is too short")
    
    static let nicknameTooLong = OSError("Nickname is too long")
    
    static let invalidNickname = OSError("Nickname cannot contain spaces")
    
    static let invalidInvite = OSError("You cannot invite yourself to a match dumbass! 🤦🏻‍♂️")
    
    static let inviteNotAllowed = OSError("You need to wait 15 minutes between every time you invite someone to a match 🕑")
    
    static let identicalUserIds = OSError("User IDs are identical")
    
    static let invalidPlayerCombo = OSError("Player combination is invalid")
    
    static let noTeamSelected = OSError("You need to be a part of a team")
    
    static let noWeekendRegistrations = OSError("Not allowed to register matches during the weekend 🍺")
    
    static let decodingFailed = OSError("Decoding failed")
    
    var errorDescription: String? {
        return message
    }
}

struct OSErrorContainer: Decodable {
    
    var errors: [String]
    
    var firstError: OSError {
        guard let message = errors.first else {
            return OSError.unknown
        }
        return OSError(message)
    }
}
