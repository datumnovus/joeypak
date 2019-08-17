//
//  AppCoordinator.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/1/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import FBSDKLoginKit
import FBSDKCoreKit
import Foundation
import UIKit

class AppCoordinator {
    static let sharedInstance        = AppCoordinator()
    private var navigationController = UINavigationController()
    private var presentedNavigationController = UINavigationController()
    private let navigationControllerDelegate = NavigationControllerDelegate()
    public var window: UIWindow {
        didSet {
            var viewController: UIViewController = LandingViewController()
            if (FBSDKAccessToken.current() != nil) {
                viewController = HomeViewController()
            }
            
            self.navigationController = UINavigationController(rootViewController: viewController)

            self.presentedNavigationController.isNavigationBarHidden = true
            self.presentedNavigationController.delegate = navigationControllerDelegate
            self.presentedNavigationController.transitioningDelegate = navigationControllerDelegate
            self.presentedNavigationController.modalPresentationStyle = UIModalPresentationStyle.custom
            self.navigationController.isNavigationBarHidden = true
            self.navigationController.delegate = navigationControllerDelegate
            
            self.window.rootViewController = self.navigationController
            self.window.makeKeyAndVisible()
        }
    }
    
    //MARK: Initializers
    init() {
        self.window = UIWindow()
    }
    
    //MARK: Actions
    @objc public func navigateBack() {
        if navigationController.presentedViewController != nil {
            navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            navigationController.popViewController(animated: true)
        }
    }
    //HACK: Make this better
    @objc public func presentedNavigateBack() {
        presentedNavigationController.popViewController(animated: true)
    }
    @objc public func navigateToLanding() {
        let viewController = LandingViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        navigationController.isNavigationBarHidden = true
        self.navigationController.delegate = navigationControllerDelegate
        
        UIView.transition(with: self.window, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            self.window.rootViewController = navigationController
        }, completion: { (finished) in
            self.navigationController = navigationController
        })
    }
    @objc public func navigateToHome() {
        if self.navigationController.viewControllers.last is LandingViewController {
            let viewController = HomeViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            
            navigationController.isNavigationBarHidden = true
            self.navigationController.delegate = navigationControllerDelegate
            
            UIView.transition(with: self.window, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.window.rootViewController = navigationController
            }, completion: { (finished) in
                self.navigationController = navigationController
            })
        }
    }
    @objc public func navigateToSettings() {
        let viewController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        viewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            viewController.dismiss(animated: true, completion: nil)
        }))
        viewController.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
            AppCoordinator.sharedInstance.navigateToShare()
        }))
        viewController.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            let manager = FBSDKLoginManager()
            manager.logOut()
            AppCoordinator.sharedInstance.navigateToLanding()
        }))
        
        navigationController.present(viewController, animated: true, completion: nil)
    }
    @objc public func navigateToShare() {
        let textToShare = "Get “The Joey” to send and receive digital currencies with your friends. "
        let url = URL(string: "https://itunes.apple.com/us/app/joeypak-mobile/id1324330311?mt=8")
        let viewController = UIActivityViewController(activityItems: [textToShare, url], applicationActivities: nil)
        
        navigationController.present(viewController, animated: true, completion: nil)
    }
    @objc public func navigateToPayViewController() {
        let viewController = PayViewController()
        presentedNavigationController.viewControllers = [viewController]
        navigationController.present(presentedNavigationController, animated: true, completion: nil)
    }
    @objc public func navigateToRequestViewController() {
        let viewController = RequestViewController()
        presentedNavigationController.viewControllers = [viewController]
        navigationController.present(presentedNavigationController, animated: true, completion: nil)
    }
    public func navigateToResponseViewController(transaction: Transaction) {
        let viewController = ResponseViewController(transaction: transaction)
        presentedNavigationController.viewControllers = [viewController]
        navigationController.present(presentedNavigationController, animated: true, completion: nil)
    }
    @objc public func navigateToLoadingViewController() {
        let viewController = LoadingViewController()
        presentedNavigationController.pushViewController(viewController, animated: true)
    }
    public func navigateToCompletedViewController(symbol: String, title: String, subtitle: String) {
        let viewController = CompletedViewController(symbol: symbol, title: title, subtitle: subtitle)
        presentedNavigationController.pushViewController(viewController, animated: true)
    }
}
