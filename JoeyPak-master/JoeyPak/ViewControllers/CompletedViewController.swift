//
//  CompletedViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/5/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class CompletedViewNode: ASDisplayNode {
    let symbolNode   = ASTextNode()
    let titleNode    = ASTextNode()
    let subtitleNode = ASTextNode()
    let buttonNode   = HighlightedButtonNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let buttonSpec = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                              verticalPosition: ASRelativeLayoutSpecPosition.end,
                                              sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                              child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 25, 15, 25), child: buttonNode))
        let textStackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                              spacing: 10,
                                              justifyContent: ASStackLayoutJustifyContent.center,
                                              alignItems: ASStackLayoutAlignItems.center,
                                              children: [symbolNode, titleNode, subtitleNode])
        let centeredTextSpec = ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY,
                                                  sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY,
                                                  child: textStackSpec)
        
        buttonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 50)
        
        return ASOverlayLayoutSpec(child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 80, 40), child: centeredTextSpec), overlay: buttonSpec)
    }
}

class CompletedViewController: ASViewController<ASDisplayNode> {
    let rootNode = CompletedViewNode()
    init() {
        super.init(node: rootNode)
        rootNode.backgroundColor = .white
    }
    convenience init(symbol: String, title: String, subtitle: String) {
        self.init()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        rootNode.buttonNode.setTitle("Okay", with: UIFont.avenirMedium(size: 18), with: UIColor.white, for: UIControlState.normal)
        rootNode.buttonNode.addTarget(AppCoordinator.sharedInstance, action: #selector(AppCoordinator.navigateBack), forControlEvents: ASControlNodeEvent.touchUpInside)
        rootNode.symbolNode.attributedText = NSAttributedString(string: symbol, attributes: [NSAttributedStringKey.font: UIFont.avenirRegular(size: 100), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        rootNode.titleNode.attributedText = NSAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 40), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        rootNode.subtitleNode.attributedText = NSAttributedString(string: subtitle, attributes: [NSAttributedStringKey.font: UIFont.avenirRegular(size: 20), NSAttributedStringKey.paragraphStyle: paragraphStyle])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
