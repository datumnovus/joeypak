//
//  HomeViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class HomeViewButton: HighlightedButtonNode {
    override init() {
        super.init()
        style.preferredSize.height = 50
        style.flexGrow = 1
    }
    convenience init(title: String) {
        self.init()
        setTitle(title, with: UIFont.avenirMedium(size: 18), with: UIColor.white, for: UIControlState.normal)
    }
}

class HomeViewNode: ASDisplayNode {
    let imageNode          = ASNetworkImageNode()
    let titleNode          = ASTextNode()
    let subtitleNode       = ASTextNode()
    let tableNode          = ASTableNode(style: UITableViewStyle.plain)
	let refreshControl     = UIRefreshControl(frame: CGRect.zero)
    let loadingNode        = LoadingViewNode(size: 50, type: .white)
    let settingsButtonNode = HomeViewButton(title: "Settings")
    let payButtonNode      = HomeViewButton(title: "Pay")
    let requestButtonNode  = HomeViewButton(title: "Request")
    
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }
    override func didLoad() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 1.2
        animation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        animation.fromValue = CGFloat(-Double.pi/2)
        animation.byValue = CGFloat(Double.pi * 2.0)
        
        loadingNode.imageNode.layer.add(animation, forKey: "refreshing")
        imageNode.layer.cornerRadius = 6
        imageNode.layer.masksToBounds = true
        refreshControl.alpha = 0
        loadingNode.alpha = 0
        
        tableNode.view.addSubview(refreshControl)
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let loadingView     = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                                   verticalPosition: ASRelativeLayoutSpecPosition.start,
                                                   sizingOption: ASRelativeLayoutSpecSizingOption.minimumSize,
                                                   child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(HomeViewController.tableHeaderViewHeight, 0, 0, 0), child: loadingNode))
        let headerStackView = ASStackLayoutSpec(direction: ASStackLayoutDirection.vertical,
                                                spacing: 10,
                                                justifyContent: ASStackLayoutJustifyContent.spaceBetween,
                                                alignItems: ASStackLayoutAlignItems.center, children: [imageNode, titleNode, subtitleNode])
        let headerViewSpec  = ASRelativeLayoutSpec(horizontalPosition: ASRelativeLayoutSpecPosition.center,
                                                   verticalPosition: ASRelativeLayoutSpecPosition.start,
                                                   sizingOption: ASRelativeLayoutSpecSizingOption.minimumHeight,
                                                   child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(37, 50, 0, 50), child: headerStackView))
        let buttonStackView = ASStackLayoutSpec(direction: ASStackLayoutDirection.horizontal,
                                                spacing: 10,
                                                justifyContent: ASStackLayoutJustifyContent.spaceBetween,
                                                alignItems: ASStackLayoutAlignItems.center,
                                                children: [settingsButtonNode, payButtonNode, requestButtonNode])
        let loadingOverSpec = ASOverlayLayoutSpec(child: headerViewSpec, overlay: loadingView)
        let tableOverlaySpec = ASOverlayLayoutSpec(child: loadingOverSpec, overlay: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(22, 0, 0, 0), child: tableNode))
        
        imageNode.style.preferredSize  = CGSize(width: 150, height: 150)
        tableNode.style.preferredSize  = constrainedSize.max
        
        return ASOverlayLayoutSpec(child: tableOverlaySpec, overlay: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(CGFloat.infinity, 15, 15, 15), child: buttonStackView))
    }
}

//TODO: make the background color of the section white
class HomeViewController: ASViewController<ASDisplayNode>, ASTableDelegate, DataSourceReloader, TransactionStoreObserver {
    static let tableHeaderViewHeight: CGFloat = 270
    private let rootNode = HomeViewNode()
    private let dataSource = HomeDataSource()
    private let tableBackgroundView = UIView(frame: CGRect(x: 0, y: 270, width: UIScreen.main.bounds.width, height: 1000))
    init() {
        super.init(node: rootNode)
        view.backgroundColor = .joeyPakGreen
        
        let paragraphStyle       = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: HomeViewController.tableHeaderViewHeight))
        tableHeaderView.backgroundColor = .clear
        
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
        tableFooterView.backgroundColor = .clear
        
        tableBackgroundView.backgroundColor = .white
        
        rootNode.imageNode.backgroundColor = .gray
        rootNode.tableNode.delegate = self
        rootNode.tableNode.dataSource = dataSource
        rootNode.tableNode.backgroundColor = .clear
        rootNode.tableNode.layer.masksToBounds = true
        rootNode.tableNode.clipsToBounds = true
        rootNode.tableNode.view.tableHeaderView = tableHeaderView
        rootNode.tableNode.view.tableFooterView = tableFooterView
        rootNode.tableNode.view.addSubview(tableBackgroundView)
        rootNode.tableNode.view.sendSubview(toBack: tableBackgroundView)
        rootNode.settingsButtonNode.addTarget(AppCoordinator.sharedInstance, action: #selector(AppCoordinator.navigateToSettings), forControlEvents: ASControlNodeEvent.touchUpInside)
        rootNode.payButtonNode.addTarget(AppCoordinator.sharedInstance, action: #selector(AppCoordinator.navigateToPayViewController), forControlEvents: ASControlNodeEvent.touchUpInside)
        rootNode.requestButtonNode.addTarget(AppCoordinator.sharedInstance, action: #selector(AppCoordinator.navigateToRequestViewController), forControlEvents: ASControlNodeEvent.touchUpInside)
        rootNode.refreshControl.addTarget(self, action: #selector(refreshControlStatusDidChange), for: UIControlEvents.valueChanged)
        dataSource.reloader = self
        
        if (UserStore.sharedInstance.currentUser != nil) {
            self.rootNode.titleNode.attributedText = NSAttributedString(string: (UserStore.sharedInstance.currentUser?.name)!, attributes: [NSAttributedStringKey.font: UIFont.avenirBold(size: 22), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
            self.rootNode.imageNode.url = UserStore.sharedInstance.currentUser?.imageURL
            self.rootNode.subtitleNode.attributedText = NSAttributedString(string: String.init(format: "%i Joeys", UserStore.sharedInstance.balence), attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 18), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
        }
        else {
            UserStore.sharedInstance.refreshCurrentUser(completion: { (user) in
                self.rootNode.titleNode.attributedText = NSAttributedString(string: (user?.name)!, attributes: [NSAttributedStringKey.font: UIFont.avenirBold(size: 22), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
                self.rootNode.imageNode.url = user?.imageURL
                self.rootNode.subtitleNode.attributedText = NSAttributedString(string: String.init(format: "%i Joeys", UserStore.sharedInstance.balence), attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 18), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
            })
        }
        
        TransactionStore.sharedInstance.addObserver(observer: self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Actions
    @objc func refreshControlStatusDidChange() {
        if self.rootNode.refreshControl.isRefreshing {
            self.rootNode.loadingNode.alpha = 1
            self.dataSource.reload(completion: { () -> Void in
                self.updateJoeyCount()
                self.rootNode.refreshControl.endRefreshing()
                self.rootNode.loadingNode.alpha = 0
            })
        }
        else {
            self.rootNode.loadingNode.alpha = 0
        }
    }
    func updateJoeyCount() {
        let paragraphStyle       = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        self.rootNode.subtitleNode.attributedText = NSAttributedString(string: String.init(format: "%i Joeys", UserStore.sharedInstance.balence), attributes: [NSAttributedStringKey.font: UIFont.avenirMedium(size: 18), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle])
    }
    
    //MARK: DataSourceReloader
    func reloadData() {
        rootNode.tableNode.view.tableNode?.reloadData()
        rootNode.refreshControl.endRefreshing()
    }
    func reloadDataAtIndexPath(indexPath: IndexPath) {
        rootNode.tableNode.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
    }
    
    //MARK: ASTableDelegate
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: 0, height: 78)
        return ASSizeRangeMake(size, size)
    }
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        let transaction = dataSource.transactionForIndexPath(indexPath: indexPath)
        if (transaction.status == .pending && transaction.fromUserId == UserStore.sharedInstance.currentUser?.uniqueId) {
            AppCoordinator.sharedInstance.navigateToResponseViewController(transaction: transaction)
        }
    }
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        rootNode.tableNode.view.sendSubview(toBack: tableBackgroundView)
    }
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
        rootNode.tableNode.view.sendSubview(toBack: tableBackgroundView)
    }
    
    //MARK: TransactionStoreObserver
    func updateTransactions(updatedTransactions: [Transaction]) {
        UserStore.sharedInstance.refreshCurrentUser { (user) in
            DispatchQueue.main.async {
                self.updateJoeyCount()
            }
        }
    }
}
