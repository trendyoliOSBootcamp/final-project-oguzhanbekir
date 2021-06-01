//
//  WishListRouter.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 29.05.2021.
//

import UIKit


final class WishListRouter {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    static func createModule() -> WishListViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(identifier: "WishListViewController") as! WishListViewController
        let interactor = WishListInteractor()
        let presenter = WishListPresenter(view: view, interactor: interactor)
        view.presenter = presenter
        interactor.output = presenter
        return view
    }
}
