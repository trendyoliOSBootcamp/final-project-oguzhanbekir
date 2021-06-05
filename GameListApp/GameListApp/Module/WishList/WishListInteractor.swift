//
//  WishListInteractor.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 29.05.2021.
//

import Foundation

protocol WishListInteractorInterface {
    func getWishListData()
}

protocol WishListInteractorOutput: AnyObject{
    func handleResult(_ result: [String:[String]])
}

final class WishListInteractor {
    weak var output: WishListInteractorOutput?
    let defaults = UserDefaults.standard
}

extension WishListInteractor: WishListInteractorInterface {
    func getWishListData() {
        if let wishListDic = defaults.dictionary(forKey: "WishList") as? [String:[String]]  {
            self.output?.handleResult(wishListDic)
        }
    }
}
