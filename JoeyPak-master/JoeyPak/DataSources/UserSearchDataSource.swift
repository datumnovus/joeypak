//
//  File.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 10/17/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol UserSearchDelegate {
    func didSelectUser(user: User)
}

class UserSearchDataSource: NSObject, ASTableDataSource {
    private var sections = [DataSourceNodeSection]()
    private var users = [User]()
    public var reloader: DataSourceReloader?
    public var delegate: UserSearchDelegate?
    
    //MARK: Helpers
    private func itemForModel(model: UserCellModel) -> DataSourceNodeItem {
        let item = DataSourceNodeItem(cellBlock: { () -> ASCellNode in
            let node = UserCellNode(model: model)
            return node
        }, selectionBlock: { (indexPath) in
            //TODO: Implement this, not sure what to do here
        })
        return item
    }
    
    //MARK: Actions
    public func updateSearch(text: String) {
        if (text.count > 0) {
            UserStore.sharedInstance.searchForUsers(searchString: text, page: 0, success: { (users) in
                DispatchQueue.main.async { [weak self] in
                    self?.users = users
                    self?.updateModels()
                }
            }) { (error) -> Void? in
                print("Update search error")
            }
        }
        else {
            DispatchQueue.main.async { [weak self] in
                self?.users = []
                self?.updateModels()
            }
        }
    }
    private func updateModels() {
        var items = [DataSourceNodeItem]()
        for user in users {
            let model = UserCellModel()
            model.title = NSAttributedString(string: user.name, attributes: UserCellNode.defaultTitleAttributes)
            model.imageURL = user.imageURL
            
            let item = self.itemForModel(model: model)
            
            items.append(item)
        }
        
        self.sections = [DataSourceNodeSection(items: items)]
        self.reloader?.reloadData()
    }
    func selectItemAtIndexPath(indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.delegate?.didSelectUser(user: user)
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
}
