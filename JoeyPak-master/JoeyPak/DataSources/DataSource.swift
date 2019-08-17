//
//  DataSourceStructure.swift
//  audit
//
//  Created by Rocco Del Priore on 8/20/17.
//  Copyright © 2017 particle. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import UIKit

struct DataSourceNodeSection {
    var title: String? = nil
    var footer: String? = nil
    
    var titleBlock: (() -> UIView)? = nil
    var footerBlock: (() -> UIView)? = nil
    
    var items: [DataSourceNodeItem]
    
    // TODO: title/footer should be view blocks
    init(title: String? = nil, titleBlock: (() -> UIView)? = nil, items: [DataSourceNodeItem], footer: String? = nil, footerBlock: (() -> UIView)? = nil) {
        self.title = title
        self.titleBlock = titleBlock
        self.footer = footer
        self.footerBlock = footerBlock
        
        self.items = items
    }
}

struct DataSourceNodeItem {
    let cellBlock: (() -> ASCellNode)
    let selectionBlock: ((IndexPath) -> Void)?
}

//TODO: Add some sort of PCReloader like functionality here
protocol DataSourceReloader {
    func reloadData()
    func reloadDataAtIndexPath(indexPath: IndexPath)
}
