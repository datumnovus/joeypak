//
//  NavigationControllerDelegate.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/5/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import UIKit

public let transitionAnimationDuration: TimeInterval = 0.295

class ModalPresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool {
        return false
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let navigationController = presented as? UINavigationController {
            if navigationController.viewControllers.first is TransactionViewController {
                return PresentTransactionAnimator()
            }
            if navigationController.viewControllers.first is ResponseViewController {
                return ResponsePresentAnimator()
            }
        }
        return nil
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let navigationController = dismissed as? UINavigationController {
            if navigationController.viewControllers.first is TransactionViewController {
                return DismissTransactionAnimator()
            }
            if navigationController.viewControllers.first is ResponseViewController {
                return ResponseDismissAnimator()
            }
        }
        return nil
    }
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if let navigationController = presented as? UINavigationController {
            if navigationController.viewControllers.first is TransactionViewController {
                return ModalPresentationController(presentedViewController: presented, presenting: presenting)
            }
            if navigationController.viewControllers.first is ResponseViewController {
                return ModalPresentationController(presentedViewController: presented, presenting: presenting)
            }
        }
        return UIPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
