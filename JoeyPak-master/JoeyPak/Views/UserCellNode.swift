//
//  UserCellNode.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 10/17/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class UserCellModel {
    public var imageURL = URL(string: "")
    public var title    = NSAttributedString(string: "")
}

class UserCellNode: ASCellNode {
    static let defaultTitleAttributes = [NSAttributedStringKey.font: UIFont.avenirRegular(size: 18), NSAttributedStringKey.foregroundColor: UIColor.black]
    
    private let imageNode    = ASNetworkImageNode()
    private let titleNode    = ASTextNode()
    
    init(model: UserCellModel) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        
        imageNode.url = model.imageURL
        titleNode.attributedText = model.title
        
        setTemporaryValues()
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                          spacing: 10,
                                          justifyContent: ASStackLayoutJustifyContent.spaceBetween,
                                          alignItems: ASStackLayoutAlignItems.center,
                                          children: [imageNode, titleNode])
        titleNode.style.flexGrow = 1
        imageNode.style.preferredSize = CGSize(width: 30, height: 30)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(10, 15, 10, 15), child: stackSpec)
    }
    override func didLoad() {
        super.didLoad()
        imageNode.layer.cornerRadius = 6
        imageNode.layer.masksToBounds = true
    }
    private func setTemporaryValues() {
        imageNode.backgroundColor = .gray
    }
}
