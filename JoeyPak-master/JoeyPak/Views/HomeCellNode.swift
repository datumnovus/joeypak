//
//  HomeCellNode.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class HomeCellModel {
    public var imageURL = URL(string: "")
    public var title    = NSAttributedString(string: "")
    public var subtitle = NSAttributedString(string: "")
    public var value    = NSAttributedString(string: "")
}

class HomeCellNode: ASCellNode {
    static let defaultTitleAttributes = [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 16), NSAttributedStringKey.foregroundColor: UIColor.black]
    static let defaultSubtitleAttributes = [NSAttributedStringKey.font: UIFont.avenirRegular(size: 16), NSAttributedStringKey.foregroundColor: UIColor.black]
    static let requestSubtitleAttributes = [NSAttributedStringKey.font: UIFont.avenirItalic(size: 16), NSAttributedStringKey.foregroundColor: UIColor.black]
    static let neutralValueAttributes = [NSAttributedStringKey.font: UIFont.avenirMedium(size: 18), NSAttributedStringKey.foregroundColor: UIColor.black]
    static let positiveValueAttributes = [NSAttributedStringKey.font: UIFont.avenirMedium(size: 18), NSAttributedStringKey.foregroundColor: UIColor.positive]
    static let negativeValueAttributes = [NSAttributedStringKey.font: UIFont.avenirMedium(size: 18), NSAttributedStringKey.foregroundColor: UIColor.negative]
    static let actionValueAttributes = [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 18), NSAttributedStringKey.foregroundColor: UIColor.action]
    
    private let imageNode    = ASNetworkImageNode()
    private let titleNode    = ASTextNode()
    private let subtitleNode = ASTextNode()
    private let valueNode    = ASTextNode()
    
    init(model: HomeCellModel) {
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .white
        imageNode.backgroundColor = .gray
        
        titleNode.attributedText    = model.title
        subtitleNode.attributedText = model.subtitle
        valueNode.attributedText    = model.value
        imageNode.url                = model.imageURL
    }
    override func didLoad() {
        super.didLoad()
        imageNode.layer.cornerRadius = 6
        imageNode.layer.masksToBounds = true
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                         spacing: 5,
                                         justifyContent: ASStackLayoutJustifyContent.start,
                                         alignItems: ASStackLayoutAlignItems.start,
                                         children: [titleNode, subtitleNode])
        let stackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                          spacing: 10,
                                          justifyContent: ASStackLayoutJustifyContent.spaceBetween,
                                          alignItems: ASStackLayoutAlignItems.center,
                                          children: [imageNode, textSpec, valueNode])
        textSpec.style.flexGrow = 1
        imageNode.style.preferredSize = CGSize(width: 57, height: 57)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 15, 5, 15), child: stackSpec)
    }
}
