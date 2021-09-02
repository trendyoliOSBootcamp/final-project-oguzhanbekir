//
//  GameListRouter.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 3.06.2021.
//

import UIKit



final class GameListRouter {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController? = nil) {
        self.navigationController = navigationController
    }
    
    static func createModule() -> GameListViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(identifier: "GameListViewController") as! GameListViewController
        let interactor = GameListInteractor()
        let presenter = GameListPresenter(view: view, interactor: interactor)
        view.presenter = presenter
        interactor.output = presenter
        return view
    }
    

}


