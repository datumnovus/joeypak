//
//  LaunchViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AsyncDisplayKit

class LandingNode: ASDisplayNode {
    let imageNode: ASImageNode = {
        var node = ASImageNode()
        node.image = UIImage(named: "JoeyIcon")
        node.contentMode = .scaleAspectFit
        return node
    }()
    let titleNode            = ASTextNode()
    let subtitleNode         = ASTextNode()
    let disclaimerNode       = ASTextNode()
    let bottomBackgroundView = ASDisplayNode()
    let facebookButton: ASDisplayNode = {
        var node = ASDisplayNode(viewBlock: { () -> UIView in
            let facebookButton = FBSDKLoginButton()
            facebookButton.readPermissions = ["public_profile", "email", "user_friends"]
            return facebookButton
        })
        return node
    }()
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    override func didLoad() {
        super.didLoad()
        
        //Round bottomBackgroundView top corners
        let bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        let maskPath = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii:CGSize(width:10.0, height:10.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        bottomBackgroundView.view.layer.mask = maskLayer
        
        //Round FacebookButton corners
        facebookButton.layer.cornerRadius = 6
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let topStackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                             spacing: 10,
                                             justifyContent: ASStackLayoutJustifyContent.spaceBetween,
                                             alignItems: ASStackLayoutAlignItems.center, children: [imageNode, titleNode, subtitleNode])
        let topViewSpec = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                               verticalPosition: ASRelativeLayoutSpecPosition.start,
                                               sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                               child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(50, 50, 0, 50), child: topStackSpec))
        let bottomBackgroundViewSpec = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                                            verticalPosition: ASRelativeLayoutSpecPosition.end,
                                                            sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                                            child: bottomBackgroundView)
        let facebookButtonSpec = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                                      verticalPosition: ASRelativeLayoutSpecPosition.end,
                                                      sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                                      child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(25, 10, 25, 10), child: facebookButton))
        let bottomViewSpec = ASOverlayLayoutSpec(child: bottomBackgroundViewSpec, overlay: facebookButtonSpec)
        let disclaimerSpec = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                                  verticalPosition: ASRelativeLayoutSpecPosition.end,
                                                  sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                                  child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 25, 100, 25), child: disclaimerNode))
        let disclaimerOverlaySpec = ASOverlayLayoutSpec(child: bottomViewSpec, overlay: disclaimerSpec)
        
        imageNode.style.preferredSize = CGSize(width: 170, height: 170)
        bottomBackgroundView.style.preferredSize.height = 100
        bottomBackgroundView.style.preferredSize.width = constrainedSize.max.width
        facebookButton.style.preferredSize.height = 55
        facebookButton.style.preferredSize.width = constrainedSize.max.width
        disclaimerNode.style.preferredSize.height = 70
        disclaimerNode.style.preferredSize.width = constrainedSize.max.width
        
        return ASOverlayLayoutSpec(child: topViewSpec, overlay: disclaimerOverlaySpec)
    }
}

class LandingViewController: ASViewController<ASDisplayNode>, FBSDKLoginButtonDelegate {
    private let rootNode = LandingNode()
    init() {
        super.init(node:rootNode)
        view.backgroundColor = .joeyPakGreen
        
        let paragraphStyle       = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let facebookButton = rootNode.facebookButton.view as! FBSDKLoginButton
        
        rootNode.titleNode.attributedText = NSAttributedString(string: "JoeyPak", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.semibold), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        rootNode.subtitleNode.attributedText = NSAttributedString(string: "Fun Money", attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 20), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        rootNode.disclaimerNode.attributedText = NSAttributedString(string: "Disclaimer: At this point you cannot purchase or sell Joey's with USD.", attributes: [NSAttributedStringKey.font: UIFont.avenirRegular(size: 16), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        rootNode.bottomBackgroundView.backgroundColor = .white
        facebookButton.delegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result != nil {
            UserStore.sharedInstance.refreshCurrentUser(completion: { (user) -> Void in
                DispatchQueue.main.async {
                    AppCoordinator.sharedInstance.navigateToHome()
                }
            })
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
}

