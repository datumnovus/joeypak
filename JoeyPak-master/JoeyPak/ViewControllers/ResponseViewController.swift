//
//  ResponseViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/5/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class ResponseViewNode: ASDisplayNode {
    let imageNode = ASNetworkImageNode()
    let titleNode = ASTextNode()
    let totalNode = ASTextNode()
    let subtitleNode = ASTextNode()
    let cancelButton = HighlightedButtonNode()
    let confirmButton = HighlightedButtonNode()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    override func didLoad() {
        super.didLoad()
        imageNode.layer.cornerRadius = 6
        imageNode.layer.masksToBounds = true
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let buttonStackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                                spacing: 10,
                                                justifyContent: ASStackLayoutJustifyContent.spaceBetween,
                                                alignItems: ASStackLayoutAlignItems.center,
                                                children: [cancelButton, confirmButton])
        let viewStackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                              spacing: 12,
                                              justifyContent: ASStackLayoutJustifyContent.center,
                                              alignItems: ASStackLayoutAlignItems.center,
                                              children: [imageNode, titleNode, totalNode, subtitleNode])
        let buttonSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(CGFloat.infinity, 25, 15, 25), child: buttonStackSpec)
        let viewSpec = ASOverlayLayoutSpec(child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(25, 25, 100, 25), child: viewStackSpec), overlay: buttonSpec)
        
        imageNode.style.preferredSize = CGSize(width: 136, height: 127)
        titleNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 30)
        totalNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 55)
        subtitleNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 26)
        cancelButton.style.preferredSize.height = 50
        cancelButton.style.flexGrow = 1
        confirmButton.style.preferredSize.height = 50
        confirmButton.style.flexGrow = 1
        
        return viewSpec
    }
}

class ResponseViewController: ASViewController<ASDisplayNode> {
    private let rootNode = ResponseViewNode()
    private var transaction: Transaction
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(node: rootNode)
        
        //Initialize Variables
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        let message = NSMutableAttributedString(string: String.init(format: "%@ on ", self.transaction.description), attributes: [NSAttributedStringKey.font: UIFont.avenirRegular(size: 16), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        
        message.append(NSAttributedString(string: formatter.string(from: transaction.date), attributes: [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 16), NSAttributedStringKey.paragraphStyle: paragraphStyle]))
        
        //Set Propeties
        rootNode.backgroundColor = .white
        rootNode.cancelButton.setTitle("Cancel", with: UIFont.avenirMedium(size: 18), with: UIColor.white, for: UIControlState.normal)
        rootNode.cancelButton.addTarget(AppCoordinator.sharedInstance, action: #selector(AppCoordinator.navigateBack), forControlEvents: ASControlNodeEvent.touchUpInside)
        rootNode.confirmButton.setTitle("Confirm", with: UIFont.avenirMedium(size: 18), with: UIColor.white, for: UIControlState.normal)
        rootNode.confirmButton.addTarget(self, action: #selector(ResponseViewController.submitConfirmation), forControlEvents: ASControlNodeEvent.touchUpInside)
        rootNode.imageNode.backgroundColor = .gray
        rootNode.subtitleNode.attributedText = message
        
        //Set User Properties
        if (transaction.toUserId != UserStore.sharedInstance.currentUser?.uniqueId) {
            rootNode.totalNode.attributedText = NSAttributedString(string: String.init(format: "-%i", transaction.value), attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 36), NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: UIColor.negative])
            UserStore.sharedInstance.fetchUser(uniqueId: transaction.toUserId) { (user) in
                self.rootNode.titleNode.attributedText = NSAttributedString(string: user.name, attributes: [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 22), NSAttributedStringKey.paragraphStyle: paragraphStyle])
                self.rootNode.imageNode.url = user.imageURL
            }
        }
        else if (transaction.fromUserId != UserStore.sharedInstance.currentUser?.uniqueId) {
            rootNode.totalNode.attributedText = NSAttributedString(string: String.init(format: "+%i", transaction.value), attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 36), NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.foregroundColor: UIColor.positive])
            UserStore.sharedInstance.fetchUser(uniqueId: transaction.fromUserId) { (user) in
                self.rootNode.titleNode.attributedText = NSAttributedString(string: user.name, attributes: [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 22), NSAttributedStringKey.paragraphStyle: paragraphStyle])
                self.rootNode.imageNode.url = user.imageURL
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func submitConfirmation() {
        AppCoordinator.sharedInstance.navigateToLoadingViewController()
        confirmRequest { () in
            UserStore.sharedInstance.fetchUser(uniqueId: self.transaction.toUserId, completion: { (user) in
                let subtitle = String.init(format: "You confirmed %@'s request for %i Joeys", user.name, self.transaction.value)
                AppCoordinator.sharedInstance.navigateToCompletedViewController(symbol: "👍", title: "Complete!", subtitle: subtitle)
            })
        }
    }
    private func confirmRequest(completion: @escaping () -> Void) {
        TransactionStore.sharedInstance.accept(transaction: self.transaction, success: { (transaction) in
            DispatchQueue.main.async {
                print("Success")
                completion()
            }
        }) { (error) -> Void? in
            DispatchQueue.main.async {
                print("Failure")
                AppCoordinator.sharedInstance.presentedNavigateBack()
                
            }
        }
    }
}
