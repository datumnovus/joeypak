//
//  HomeDataSource.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class HomeDataSource: NSObject, ASTableDataSource, TransactionStoreObserver {
    private var sections = [DataSourceNodeSection]()
    private var transactions = [[Transaction]]()
    public var reloader: DataSourceReloader?
    
    //MARK: Initializers
    override init() {
        super.init()
        TransactionStore.sharedInstance.addObserver(observer: self)
        UserStore.sharedInstance.refreshCurrentUser { (user) in
            TransactionStore.sharedInstance.fetchTransactionHistory(page: 0, success: nil, failure: nil)
        }
    }
    
    //MARK: Helpers
    private func areDatesInTheSameSection(one: Date, two: Date) -> Bool {
        let calendar = Calendar.current
        if (calendar.component(.year, from: one) != calendar.component(.year, from: two)) {
            return false
        }
        if (calendar.component(.month, from: one) != calendar.component(.month, from: two)) {
            return false
        }
        return true
    }
    
    //Actions
    public func reload(completion: (() -> Void?)?) {
        UserStore.sharedInstance.refreshCurrentUser { (user) in
            TransactionStore.sharedInstance.fetchTransactionHistory(page: 0, success: { (transactions) -> Void? in
                DispatchQueue.main.async {
                    completion?()
                }
            }, failure: { (error) -> Void? in
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    //MARK: Accessors
    private func modelForTransaction(transaction: Transaction) -> HomeCellModel {
        let model = HomeCellModel()
        
        //Fetch User Details
        let userCompletionBlock: (User) -> Void = { (user) in
            model.title = NSAttributedString(string: user.name, attributes: HomeCellNode.defaultTitleAttributes)
            model.imageURL = user.imageURL
            
            DispatchQueue.main.async {
                guard
                    let indexPath = self.indexPathForTransaction(transaction: transaction)
                    else {
                        self.reloader?.reloadData()
                        return
                }
                self.reloader?.reloadDataAtIndexPath(indexPath: indexPath)
            }
        }
        //Fetch Current User
        let currentUserCompletionBlock: (User?) -> Void  = { (currentUser) in
            //Set value
            if (transaction.toUserId == currentUser?.uniqueId) {
                if (transaction.status == .pending) {
                    model.value = NSAttributedString(string: "Waiting", attributes: HomeCellNode.neutralValueAttributes)
                    model.subtitle = NSAttributedString(string: String.init(format: "J %i Requested", transaction.value), attributes: HomeCellNode.requestSubtitleAttributes)
                }
                else {
                    model.value = NSAttributedString(string: String.init(format: "+%i", transaction.value), attributes: HomeCellNode.positiveValueAttributes)
                    model.subtitle = NSAttributedString(string: transaction.description, attributes: HomeCellNode.defaultSubtitleAttributes)
                }
            }
            else if (transaction.fromUserId == currentUser?.uniqueId) {
                if (transaction.status == .pending) {
                    model.value = NSAttributedString(string: "Respond", attributes: HomeCellNode.actionValueAttributes)
                    model.subtitle = NSAttributedString(string: String.init(format: "Requests J %i", transaction.value), attributes: HomeCellNode.requestSubtitleAttributes)
                }
                else {
                    model.value = NSAttributedString(string: String.init(format: "-%i", transaction.value), attributes: HomeCellNode.negativeValueAttributes)
                    model.subtitle = NSAttributedString(string: transaction.description, attributes: HomeCellNode.defaultSubtitleAttributes)
                }
            }
            
            //Fetch Other User
            if (transaction.toUserId != UserStore.sharedInstance.currentUser?.uniqueId) {
                UserStore.sharedInstance.fetchUser(uniqueId: transaction.toUserId, completion:userCompletionBlock)
            }
            else if (transaction.fromUserId != UserStore.sharedInstance.currentUser?.uniqueId) {
                UserStore.sharedInstance.fetchUser(uniqueId: transaction.fromUserId, completion:userCompletionBlock)
            }
        }
        
        //Grab Current User as needed
        if UserStore.sharedInstance.currentUser != nil {
            currentUserCompletionBlock(UserStore.sharedInstance.currentUser)
        }
        else {
            UserStore.sharedInstance.refreshCurrentUser(completion: currentUserCompletionBlock)
        }
        
        return model
    }
    private func itemForModel(model: HomeCellModel) -> DataSourceNodeItem {
        let item = DataSourceNodeItem(cellBlock: { () -> ASCellNode in
            let node = HomeCellNode(model: model)
            return node
        }, selectionBlock: { (indexPath) in
            //TODO: Implement this, not sure what to do here
        })
        return item
    }
    func transactionForIndexPath(indexPath: IndexPath) -> Transaction {
        return self.transactions[indexPath.section][indexPath.row]
    }
    func indexPathForTransaction(transaction: Transaction) -> IndexPath? {
        if (transactions.count > 0) {
            for section in 0..<transactions.count {
                let row = transactions[section].index(of: transaction)
                if (row != NSNotFound && row != nil) {
                    return IndexPath(row: row!, section: section)
                }
            }
        }
        return nil
    }
 
    //MARK: ASTableDataSource
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return sections.count
    }
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return sections[indexPath.section].items[indexPath.row].cellBlock
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let transaction = transactionForIndexPath(indexPath: IndexPath(row: 0, section: section))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: transaction.date)
    }
    
    //MARK: TransactionStoreObserver
    func updateTransactions(updatedTransactions: [Transaction]) {
        var transactionsToAdd = [Transaction]()
        
        //Update Existing Transaction
        for transaction in updatedTransactions {
            guard
                let indexPath = self.indexPathForTransaction(transaction: transaction)
                else {
                    transactionsToAdd.append(transaction)
                    continue
            }
            
            transactions[indexPath.section][indexPath.row] = transaction
            sections[indexPath.section].items[indexPath.row] = itemForModel(model: modelForTransaction(transaction: transaction))
            reloader?.reloadDataAtIndexPath(indexPath: indexPath)
        }
        
        //Add New Transactions
        if transactionsToAdd.count > 0 {
            //Initialize Variables
            var models = [[HomeCellModel]]()
            var transactions = [[Transaction]]()
            var transactionSection = [Transaction]()
            var sections = [DataSourceNodeSection]()
            let totalTransactions: [Transaction] = {
                var total = self.transactions.flatMap({$0})
                total.append(contentsOf: transactionsToAdd)
                return total
            }()
            
            //Sort transactions
            for transaction in totalTransactions.sorted(by: { (one, two) -> Bool in
                return one.date > two.date
            }) {
                if (transactionSection.count == 0) {
                    transactionSection.append(transaction)
                }
                else if (!areDatesInTheSameSection(one: (transactionSection.first?.date)!, two: transaction.date)) {
                    transactions.append(transactionSection)
                    transactionSection = [transaction]
                }
                else {
                    transactionSection.append(transaction)
                }
            }
            transactions.append(transactionSection)
            
            //Populate Models
            for section in transactions  {
                var modelSection = [HomeCellModel]()
                for transaction in section {
                    modelSection.append(modelForTransaction(transaction: transaction))
                }
                models.append(modelSection)
            }
            
            //Populate Items
            for section in models {
                var items = [DataSourceNodeItem]()
                for model in section {
                    items.append(itemForModel(model: model))
                }
                sections.append(DataSourceNodeSection(items: items))
            }
            
            //Set Globals
            self.transactions = transactions
            self.sections = sections
            reloader?.reloadData()
        }
    }
}
