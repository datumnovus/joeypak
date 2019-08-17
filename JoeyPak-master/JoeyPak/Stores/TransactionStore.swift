//
//  TransactionStore.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/19/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import Foundation
import ParticleExtensions

protocol TransactionStoreObserver {
    func updateTransactions(updatedTransactions: [Transaction])
}

class TransactionStore {
    private static let newTransactionEndpoint = "new_transaction"
    private static let acceptTransactionEndpoint = "accept_transaction"
    private static let transactionHistoryEndpoint = "all_transactions"
    private static let toKey = "to"
    private static let fromKey = "from"
    private static let valueKey = "value"
    private static let descriptionKey = "description"
    private static let pageKey = "page"
    private static let transactionIdKey = "transfer_id"
    static let sharedInstance = TransactionStore()
    private let rootURL = URL(string: "http://13.56.210.36:3000/")
    private var transactions = [String: Transaction]()
    private var observers = [TransactionStoreObserver?]()
    
    //MARK: Actions
    public func addObserver(observer: TransactionStoreObserver) {
        observers.append(observer)
    }
    public func send(joeys: Int, to user: User, with description: String, success: @escaping (Transaction) -> Void, failure: @escaping (Error?) -> Void?) {
        guard let currentUser = UserStore.sharedInstance.currentUser else {
            failure(nil)
            return
        }
        
        newTransaction(to: user, from: currentUser, joeys: joeys, description: description, success: success, failure: failure)
    }
    public func request(joeys: Int, from user: User, with description: String, success: @escaping (Transaction) -> Void, failure: @escaping (Error?) -> Void?) {
        guard let currentUser = UserStore.sharedInstance.currentUser else {
            failure(nil)
            return
        }
        
        newTransaction(to: currentUser, from: user, joeys: joeys, description: description, success: success, failure: failure)
    }
    public func accept(transaction: Transaction, success: @escaping (Transaction) -> Void, failure: @escaping (Error?) -> Void?) {
        //Declare Variables
        guard
            let url = rootURL?.appendingWebComponent(component: TransactionStore.acceptTransactionEndpoint),
            let authToken = UserStore.sharedInstance.authToken else {
            return
        }
        
        //Configure Request
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
        request.setJSONBody(json: [UserStore.authTokenKey: authToken, TransactionStore.transactionIdKey: transaction.uniqueId])
        request.httpMethod = "POST"
        
        //Make Request
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request as URLRequest) { (data, response, error) in
            if data != nil {
                do {
                    let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Dictionary<String, Any>
                    
                    print("JSON: ", json)
                    if json.keys.contains("err") {
                        failure(error)
                    }
                    else if let transaction = self.addOrUpdateTransaction(transactionJSON: json) {
                        success(transaction)
                    }
                    else {
                        failure(error)
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            else {
                failure(error)
            }
        }
        task.resume()
    }
    
    //MARK: Accessors
    public func fetchTransactionHistory(page: Int, success: (([Transaction]) -> Void?)?, failure: ((Error?) -> Void?)?) {
        //Declare Variables
        guard
            var url = rootURL?.appendingWebComponent(component: TransactionStore.transactionHistoryEndpoint),
            let authToken = UserStore.sharedInstance.authToken else {
            return
        }
        
        //Configure Parameters
        url.setParameters(parameters: [UserStore.authTokenKey: authToken, TransactionStore.pageKey: String.init(format: "%i", page)])
        
        //Configure Request
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
        request.httpMethod = "GET"
        
        //Make Request
        let task = URLSession.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
            if data != nil {
                do {
                    let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Array<Dictionary<String, Any>>
                    let transactions = self.addOrUpdateTransactions(transactionsJSON: json)
                    success?(transactions)
                } catch let error as NSError {
                    failure?(error)
                }
            }
            else {
                failure?(error)
            }
        }
        task.resume()
    }
    
    //MARK: Helpers
    private func newTransaction(to: User, from: User, joeys: Int, description: String, success: @escaping (Transaction) -> Void, failure: @escaping (Error?) -> Void?) {
        //Declare Variables
        guard
            let url = rootURL?.appendingWebComponent(component: TransactionStore.newTransactionEndpoint),
            let authToken = UserStore.sharedInstance.authToken else {
                return
        }
        
        let jsonBody = [UserStore.authTokenKey: authToken, TransactionStore.toKey: to.uniqueId, TransactionStore.fromKey: from.uniqueId, TransactionStore.valueKey: joeys, TransactionStore.descriptionKey: description] as [String : Any]
        
        //Configure Request
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
        request.setJSONBody(json: jsonBody)
        request.httpMethod = "POST"
        
        //Make Request
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request as URLRequest) { (data, response, error) in
            if data != nil {
                do {
                    let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Dictionary<String, Any>
                    if let transaction = self.addOrUpdateTransaction(transactionJSON: json) {
                        success(transaction)
                    }
                    else {
                        failure(error)
                    }
                } catch let error as NSError {
                    failure(error)
                }
            }
            else {
                failure(error)
            }
        }
        task.resume()
    }
    private func addOrUpdateTransactions(transactionsJSON: [[String: Any]]) -> [Transaction] {
        var updatedTransactions = [Transaction]()
        for json in transactionsJSON {
            let key = json[Transaction.uniqueIdKey] as! String
            if (transactions.keys.contains(key)) {
                transactions[key]!.update(json: json)
            }
            else {
                transactions[key] = Transaction(json: json)
            }
            updatedTransactions.append(transactions[key]!)
        }
        DispatchQueue.main.async {
            self.observers.forEach { $0?.updateTransactions(updatedTransactions: updatedTransactions) }
        }
        return updatedTransactions
    }
    private func addOrUpdateTransaction(transactionJSON: [String: Any]) -> Transaction? {
        let key = transactionJSON[Transaction.uniqueIdKey] as! String
        if (transactions.keys.contains(key)) {
            transactions[key]!.update(json: transactionJSON)
        }
        else {
            transactions[key] = Transaction(json: transactionJSON)
        }
        let transaction = transactions[key]!
        
        DispatchQueue.main.async {
            self.observers.forEach { $0?.updateTransactions(updatedTransactions: [transaction]) }
        }
        
        return transaction
    }
}
