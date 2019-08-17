//
//  Transaction.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/19/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import Foundation

struct Transaction {
    enum Status {
        case pending, complete
    }
    static let uniqueIdKey    = "transfer_id"
    static let toUserIdKey    = "to"
    static let fromUserIdKey  = "from"
    static let valueKey       = "value"
    static let dateKey        = "date"
    static let descriptionKey = "description"
    static let statusKey      = "status"
    private(set) public var uniqueId: String
    private(set) public var toUserId: String
    private(set) public var fromUserId: String
    private(set) public var value: Int
    private(set) public var date: Date
    private(set) public var description: String
    private(set) public var status: Status
}

extension Transaction {
    init?(json: [String: Any]) {
        guard
            let uniqueId    = json[Transaction.uniqueIdKey] as? String,
            let toUserId    = json[Transaction.toUserIdKey] as? String,
            let fromUserId  = json[Transaction.fromUserIdKey] as? String,
            let description = json[Transaction.descriptionKey] as? String,
            let epoch       = json[Transaction.dateKey] as? TimeInterval,
            let status      = json[Transaction.statusKey] as? Int
        else {
            return nil
        }
        
        var value = 0
        if json[Transaction.valueKey] is Int {
            value = json[Transaction.valueKey] as! Int
        }
        else if json[Transaction.valueKey] is String {
            value = Int((json[Transaction.valueKey] as? String)!)!
        }
        
        self.uniqueId    = uniqueId
        self.toUserId    = toUserId
        self.fromUserId  = fromUserId
        self.value       = value
        self.date        = Date(timeIntervalSince1970: (epoch*0.001))
        self.description = description

        switch status {
            case 0:
                self.status = .pending
            default:
                self.status = .complete
        }
    }
    public mutating func update(json: [String: Any]) {
        guard
            let toUserId    = json[Transaction.toUserIdKey] as? String,
            let fromUserId  = json[Transaction.fromUserIdKey] as? String,
            let epoch       = json[Transaction.dateKey] as? TimeInterval,
            let description = json[Transaction.descriptionKey] as? String,
            let status      = json[Transaction.statusKey] as? Int
        else {
            return
        }
        
        var value = 0
        if json[Transaction.valueKey] is Int {
            value = json[Transaction.valueKey] as! Int
        }
        else if json[Transaction.valueKey] is String {
            value = Int((json[Transaction.valueKey] as? String)!)!
        }
        
        self.toUserId    = toUserId
        self.fromUserId  = fromUserId
        self.value       = value
        self.date        = Date(timeIntervalSince1970: (epoch*0.001))
        self.description = description
        
        switch status {
        case 0:
            self.status = .pending
            break
        default:
            self.status = .complete
            break
        }
    }
}

extension Transaction: Equatable {
    static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.uniqueId == rhs.uniqueId && rhs.uniqueId == lhs.uniqueId
    }
}
