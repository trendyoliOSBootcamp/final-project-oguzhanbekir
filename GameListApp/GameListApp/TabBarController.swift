//
//  TabBarController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 31.05.2021.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildViewControllers()
    }
    
    private func setupChildViewControllers() {
        guard let viewControllers = viewControllers else { return }

        for viewController in viewControllers {
            var childViewController: UIViewController?
            if let navigationController = viewController as? UINavigationController {
                childViewController = navigationController.viewControllers.first
                let vc = WishListRouter.createModule()
                if let _ = childViewController as? WishListViewController {
                    navigationController.setViewControllers([vc!], animated: true)
                }
            }
        }
    }
}
