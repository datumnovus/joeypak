//
//  TransactionViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/2/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit
import ParticleExtensions

//TODO: Clean up the quick coding here
class TransactionInputNode: ASDisplayNode {
    let label = ASTextNode()
    let input = ASEditableTextNode()
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let viewSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                         spacing: 18,
                                         justifyContent: ASStackLayoutJustifyContent.start,
                                         alignItems: ASStackLayoutAlignItems.center,
                                         children: [label, input])
        
        label.style.preferredSize = CGSize(width: 40, height: constrainedSize.max.height)
        input.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height)
        
        return viewSpec
    }
}

class TransactionViewNode: ASDisplayNode {
    let closeButton: ASButtonNode = {
        var node = ASButtonNode()
        node.setImage(UIImage(named: "CloseButton"), for: UIControlState.normal)
        return node
    }()
    let confirmButton = HighlightedButtonNode()
    let priceNode: ASEditableTextNode = {
        var node = ASEditableTextNode()
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        node.keyboardType = UIKeyboardType.decimalPad
        node.attributedText = NSAttributedString(string: "J ", attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 46), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        node.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.avenirMedium(size: 46), NSAttributedStringKey.paragraphStyle.rawValue: paragraphStyle]
        return node
    }()
    let userNode = TransactionInputNode()
    let forNode = TransactionInputNode()
    private let seperatorNode: ASDisplayNode = {
        var node = ASDisplayNode()
        node.backgroundColor = UIColor.joeyPakGray
        return node
    }()
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let closeButtonSpec = ASAbsoluteLayoutSpec(children: [closeButton])
        let confirmButtonSpec = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                                     verticalPosition: ASRelativeLayoutSpecPosition.end,
                                                     sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                                     child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 15, 15, 15), child: confirmButton))
        let priceSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(65, 25, 0, 25), child: priceNode)
        let userSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 15, 0, 0), child: userNode)
        let forSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 15, 0, 0), child: forNode)
        let stackSpec = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                          spacing: 7,
                                          justifyContent: ASStackLayoutJustifyContent.start,
                                          alignItems: ASStackLayoutAlignItems.center,
                                          children: [priceSpec, userSpec, seperatorNode, forSpec])
        let closeButtonOverlaySpec = ASOverlayLayoutSpec(child: stackSpec, overlay: closeButtonSpec)
        let confirmButtonOverlaySpec = ASOverlayLayoutSpec(child: closeButtonOverlaySpec, overlay: confirmButtonSpec)
        
        closeButton.style.layoutPosition = CGPoint(x: 23, y: 23)
        closeButton.style.preferredSize = CGSize(width: 32, height: 32)
        priceNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 65)
        userNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 35)
        forNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 35)
        seperatorNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 1)
        confirmButton.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 50)
        
        return confirmButtonOverlaySpec
    }
}

class TransactionViewController: ASViewController<ASDisplayNode>, ASEditableTextNodeDelegate, UserSearchDelegate {
    private var searchViewController: UserSearchViewController?
    fileprivate let rootNode = TransactionViewNode()
    fileprivate var user: User? {
        didSet {
            if let newUser = user as User! {
                let attributes = [NSAttributedStringKey.font: UIFont.avenirDemiBold(size: 20), NSAttributedStringKey.foregroundColor: UIColor(hex: 0x007AFF)]
                rootNode.userNode.input.attributedText = NSAttributedString(string: newUser.name, attributes: attributes)
            }
            else {
                rootNode.userNode.input.attributedText = NSAttributedString(string: "")
            }
        }
    }
    //HACK: Becuase of ASDisplayKit constraints, the button node wll snap back in place whenever a view is added/remove
    //CONT: This caches the previous frame so we can reset it anytime that happens.
    private var lastKnownKeyboardFrame: CGRect?
    
    //MARK: Initializers
    init() {
        super.init(node: rootNode)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let labelAttributes = [NSAttributedStringKey.font: UIFont.avenirMedium(size: 20), NSAttributedStringKey.paragraphStyle: paragraphStyle]
        let placeholderAttributes = [NSAttributedStringKey.font: UIFont.avenirRegular(size: 20), NSAttributedStringKey.foregroundColor: UIColor.gray]
        
        rootNode.backgroundColor = .white
        rootNode.priceNode.delegate = self
        rootNode.userNode.input.delegate = self
        rootNode.userNode.label.attributedText = NSAttributedString(string: "To:", attributes: labelAttributes)
        rootNode.userNode.input.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.avenirRegular(size: 20)]
        rootNode.userNode.input.attributedPlaceholderText = NSAttributedString(string: "Start typing a name", attributes:placeholderAttributes)
        rootNode.forNode.input.delegate = self
        rootNode.forNode.input.maximumLinesToDisplay = 1
        rootNode.forNode.label.attributedText = NSAttributedString(string: "For:", attributes: labelAttributes)
        rootNode.forNode.input.typingAttributes = [NSAttributedStringKey.font.rawValue: UIFont.avenirRegular(size: 20)]
        rootNode.forNode.input.attributedPlaceholderText = NSAttributedString(string: "Whats it for?", attributes: placeholderAttributes)
        rootNode.closeButton.addTarget(AppCoordinator.sharedInstance, action: #selector(AppCoordinator.navigateBack), forControlEvents: ASControlNodeEvent.touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.showKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootNode.priceNode.becomeFirstResponder()
        if let location = rootNode.priceNode.attributedText?.string.count {
            rootNode.priceNode.selectedRange = NSRange(location: location, length: 0)
        }
    }
    
    //MARK: Actions
    private func showUserSearch() {
        if searchViewController == nil {
            //Clear User
            self.user = nil
            
            //Initialize SearchViewController
            searchViewController = UserSearchViewController()
            searchViewController?.dataSource.delegate = self
            
            let y = rootNode.userNode.frame.origin.y+rootNode.userNode.frame.size.height
            let height = self.view.frame.size.height-y
            
            //Add View
            searchViewController?.view.frame = CGRect(x: 0, y: y, width: self.view.frame.size.width, height: height)
            view.addSubview((searchViewController?.view)!)
            
            //Add Child View Controller
            addChildViewController(searchViewController!)
            searchViewController!.didMove(toParentViewController: self)
        }
    }
    private func hideUserSearch() {
        if searchViewController != nil {
            //HACK: Confirm button still constrained, wait until we can break
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                if let frame = self.lastKnownKeyboardFrame {
                    self.rootNode.confirmButton.view.frame = frame
                }
            }
            
            rootNode.forNode.input.becomeFirstResponder()
            searchViewController?.view.removeFromSuperview()
            searchViewController = nil
        }
    }
    
    //MARK: Accessors
    fileprivate func numberOfJoeys() -> Int {
        //TODO: Clean up this garbage
        let rawString = self.rootNode.priceNode.attributedText?.string
        let start = rawString?.index((rawString?.startIndex)!, offsetBy: 2)
        let end = rawString?.index((rawString?.endIndex)!, offsetBy: 0)
        let range = start!..<end!
        let floatString = Float((rawString?.substring(with: range).trimmingCharacters(in: .whitespaces))!)
        
        return Int(floor(floatString!))
    }
    
    //MARK: UserSearchDelegate
    func didSelectUser(user: User) {
        self.user = user
        hideUserSearch()
    }
    
    //MARK: ASEditableTextNodeDelegate
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if editableTextNode == rootNode.priceNode {
            if range.contains(0) || range.contains(1) || range.location == 0 || range.location == 1 {
                return false
            }
        }
        else if editableTextNode == rootNode.userNode.input {
            if text == "\n" {
                editableTextNode.resignFirstResponder()
                return false
            }
            else {
                var string = editableTextNode.attributedText?.string as? NSString
                let astring = string?.replacingCharacters(in: range, with: text)
                if let finalvalue = astring as? String {
                    searchViewController?.dataSource.updateSearch(text: finalvalue)
                }
            }
        }
        else if editableTextNode == rootNode.forNode.input {
            if text == "\n" {
                return false
            }
            guard let oldText = editableTextNode.attributedText else {
                return true
            }
            if oldText.string.count >= 140 {
                return false
            }
        }
        return true
    }
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        if editableTextNode == rootNode.userNode.input {
            showUserSearch()
        }
        else {
            hideUserSearch()
        }
    }
    
    //MARK: Keyboard Responders
    @objc func showKeyboard(notification: NSNotification) {
        let keyboardFrameBeginRect: CGRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let option = UIViewAnimationOptions(rawValue: UInt((notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let duration: TimeInterval = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let finalFrameForConfirmButton: CGRect = {
            var frame = rootNode.confirmButton.frame
            frame.origin.y = rootNode.frame.height-keyboardFrameBeginRect.height-frame.height-15
            return frame
        }()
        
        self.lastKnownKeyboardFrame = finalFrameForConfirmButton
        UIView.animate(withDuration: duration, delay: 0.0, options: option, animations: {
            self.rootNode.confirmButton.frame = finalFrameForConfirmButton
        }, completion: nil)
    }
}

class PayViewController: TransactionViewController {
    override init() {
        super.init()
        rootNode.confirmButton.setTitle("Confirm Payment", with: UIFont.avenirDemiBold(size: 18), with: UIColor.white, for: UIControlState.normal)
        rootNode.confirmButton.addTarget(self, action: #selector(PayViewController.submitConfirmation), forControlEvents: ASControlNodeEvent.touchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func submitConfirmation() {
        guard let toUser = self.user as? User else {
            return
        }
        
        AppCoordinator.sharedInstance.navigateToLoadingViewController()
        
        TransactionStore.sharedInstance.send(joeys: self.numberOfJoeys(), to: toUser, with: (self.rootNode.forNode.input.attributedText?.string)!, success: { (transaction) in
            DispatchQueue.main.async { [weak self] in
                let subtitle = String.init(format: "You sent %@ %li Joeys.", (self?.user?.name)!, transaction.value)
                AppCoordinator.sharedInstance.navigateToCompletedViewController(symbol: "👍", title: "Success!", subtitle: subtitle)
            }
        }) { (error) -> Void? in
            print("Failed to send joeys")
        }
    }
}

class RequestViewController: TransactionViewController {
    override init() {
        super.init()
        rootNode.confirmButton.setTitle("Confirm Request", with: UIFont.avenirDemiBold(size: 18), with: UIColor.white, for: UIControlState.normal)
        rootNode.confirmButton.addTarget(self, action: #selector(RequestViewController.submitConfirmation), forControlEvents: ASControlNodeEvent.touchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func submitConfirmation() {
        guard let fromUser = self.user as? User else {
            return
        }
        
        AppCoordinator.sharedInstance.navigateToLoadingViewController()
        
        TransactionStore.sharedInstance.request(joeys: self.numberOfJoeys(), from: fromUser, with: (self.rootNode.forNode.input.attributedText?.string)!, success: { (transaction) in
            DispatchQueue.main.async { [weak self] in
                let subtitle = String.init(format: "You requested %li Joeys from %@.", transaction.value, (self?.user?.name)!)
                AppCoordinator.sharedInstance.navigateToCompletedViewController(symbol: "👍", title: "Success!", subtitle: subtitle)
            }
        }) { (error) -> Void? in
            print("Failed to request joeys")
        }
    }
}
