//
//  TransactionAnimator.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/5/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import UIKit

fileprivate let shadowTag: Int = 1738

class PresentTransactionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionAnimationDuration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Instantiate Initial Values
        guard
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UINavigationController,
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UINavigationController else {
                return
        }
        let container = transitionContext.containerView
        let shadow = UIView(frame: container.bounds)
        
        //Set Up Container
        container.addSubview(shadow)
        container.addSubview(toViewController.view)
        
        //Calculate Frames
        let statusBarHeight: CGFloat = 22.0
        let initalFrameForToViewController: CGRect = {
            var frame = toViewController.view.frame
            frame.origin.y = fromViewController.view.frame.height
            frame.size.height = fromViewController.view.frame.height-statusBarHeight
            return frame
        }()
        let finalFrameForToViewController: CGRect = {
            var frame = toViewController.view.frame
            frame.origin.y = statusBarHeight
            frame.size.height = fromViewController.view.frame.height-statusBarHeight
            return frame
        }()
        
        //Set Initial Values
        shadow.alpha = 0
        shadow.tag = shadowTag
        shadow.backgroundColor = .black
        toViewController.view.frame = initalFrameForToViewController
        
        //Round toViewController top corners
        let bounds = CGRect(x: 0, y: 0, width: initalFrameForToViewController.width, height: initalFrameForToViewController.height)
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii:CGSize(width:10.0, height:10.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        toViewController.view.layer.mask = maskLayer
        
        //Perform Animation
        UIView.animate(withDuration: transitionAnimationDuration, delay: 0.0, options: .curveEaseInOut, animations: {
            //Update Frame
            toViewController.view.frame = finalFrameForToViewController
            
            //Update Shadow
            shadow.alpha = 0.35
        }) { (finished) in
            //Finish Transition
            transitionContext.completeTransition(finished)
        }
    }
}

class DismissTransactionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionAnimationDuration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Instantiate Initial Values
        guard
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? UINavigationController,
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? UINavigationController else {
            return
        }
        let container = transitionContext.containerView
        let shadow = container.viewWithTag(shadowTag)
        
        //Calculate Frames
        let finalFrameForFromViewController: CGRect = {
            var frame = fromViewController.view.frame
            frame.origin.y = toViewController.view.frame.height
            return frame
        }()
        
        //Perform Animation
        UIView.animate(withDuration: transitionAnimationDuration, delay: 0.0, options: .curveEaseInOut, animations: {
            //Update Frame
            fromViewController.view.frame = finalFrameForFromViewController
            
            //Update Shadow
            shadow?.alpha = 0.0
        }) { (finished) in
            //Reset Values
            shadow?.removeFromSuperview()
            
            //Finish Transition
            transitionContext.completeTransition(finished)
        }
    }
}
