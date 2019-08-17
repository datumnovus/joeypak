//
//  LoadingViewController.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/5/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import AsyncDisplayKit

class LoadingViewNode: ASDisplayNode {
    enum type {
        case green, white
    }
    
    let imageNode: ASImageNode = {
        var imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
        return imageNode
    }()
    private let size: CGFloat
    init(size: CGFloat, type: type) {
        self.size = size
        super.init()
        automaticallyManagesSubnodes = true
        
        switch type {
            case .green:
                imageNode.image = UIImage(named: "Loading")
            case .white:
                imageNode.image = UIImage(named: "Loading White")
        }
    }
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.preferredSize = CGSize(width: size, height: size)
        return ASCenterLayoutSpec(centeringOptions: ASCenterLayoutSpecCenteringOptions.XY, sizingOptions: ASCenterLayoutSpecSizingOptions.minimumXY, child: imageNode)
    }
}

class LoadingViewController: ASViewController<ASDisplayNode> {
    private let rootNode = LoadingViewNode(size: 200, type: .green)
    init() {
        super.init(node: rootNode)
        rootNode.backgroundColor = .white
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 1.2
        animation.repeatCount = Float(CGFloat.greatestFiniteMagnitude)
        animation.fromValue = CGFloat(-Double.pi/2)
        animation.byValue = CGFloat(Double.pi * 2.0)
        
        rootNode.imageNode.layer.add(animation, forKey: "refreshing")
    }
}
