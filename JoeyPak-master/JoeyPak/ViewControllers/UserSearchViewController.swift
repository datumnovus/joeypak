//
//  UserSearchViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 10/16/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class UserSearchNode: ASDisplayNode {
    let tableNode = ASTableNode(style: UITableViewStyle.plain)
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        tableNode.backgroundColor = .white
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: tableNode)
    }
}

class UserSearchViewController: ASViewController<ASDisplayNode>, ASTableDelegate, DataSourceReloader {
    private let rootNode = UserSearchNode()
    let dataSource = UserSearchDataSource()
    
    init() {
        super.init(node: rootNode)
        rootNode.backgroundColor = .white
        rootNode.tableNode.dataSource = dataSource
        rootNode.tableNode.delegate = self
        dataSource.reloader = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ASTableDelegate
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        dataSource.selectItemAtIndexPath(indexPath: indexPath)
    }
    
    //MARK: DataSourceReloader
    func reloadData() {
        rootNode.tableNode.view.tableNode?.reloadData()
    }
    func reloadDataAtIndexPath(indexPath: IndexPath) {
        rootNode.tableNode.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
}
