//
//  File.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/19/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import Foundation

struct User {
    static let uniqueIdKey = "fb_uid"
    static let nameKey     = "name"
    static let imageURLKey = "image"
    static let fbImageURLKey = "fb_img"
    private(set) public var uniqueId: String
    private(set) public var name: String
    private(set) public var imageURL: URL?
}

extension User {
    init?(json: [String: Any]) {
        guard
            let uniqueId = json[User.uniqueIdKey] as? String,
            let name     = json[User.nameKey] as? String
        else {
            return nil
        }
        
        self.uniqueId = uniqueId
        self.name     = name
            
        if let imageURL = json[User.imageURLKey] as? URL {
            self.imageURL = imageURL
        }
        else if let imageURL = json[User.imageURLKey] as? String {
            self.imageURL = URL(string: imageURL)
        }
        else if let imageURL = json[User.fbImageURLKey] as? URL {
            self.imageURL = imageURL
        }
        else if let imageURL = json[User.fbImageURLKey] as? String {
            self.imageURL = URL(string: imageURL)
        }
    }
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.uniqueId == rhs.uniqueId && rhs.uniqueId == lhs.uniqueId
    }
}
