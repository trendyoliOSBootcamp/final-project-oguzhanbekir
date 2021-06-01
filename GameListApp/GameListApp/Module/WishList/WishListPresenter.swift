//
//  WishListPresenter.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 29.05.2021.
//

import Foundation

protocol WishListPresenterInterface {
    var numberOfItems: Int { get }
    var cellPadding: Double { get }
    
    func load()
    func wishList(_ index: Int) -> [String]
    func calculateCellSize(collectionViewWidth: Double) -> (width: Double, height: Double)
    func removeFromWishList(_ index: Int)
}

extension WishListPresenter {
    fileprivate enum Constants {
        static let cellLeftPadding: Double = 16
        static let cellRightPadding: Double = 16

        static let cellBannerImageViewAspectRatio: Double = 1
        static let cellDescriptionViewHeight: Double = 72
    }
}

final class WishListPresenter {
    let defaults = UserDefaults.standard
    private var wishListDict: [String:[String]] = [:]
    
    weak var view: WishListInterface?
    private let interactor: WishListInteractorInterface
    
    init(view: WishListInterface, interactor: WishListInteractorInterface) {
        self.view = view
        self.interactor = interactor
    }

    private func getWishListData() {
        interactor.getWishListData()
    }

}

extension WishListPresenter: WishListPresenterInterface {
    func removeFromWishList(_ index: Int) {
        wishListDict.removeValue(forKey: "\(wishListDict[index].key)")
        defaults.set(wishListDict, forKey:"WishList")
        view?.reloadData()
    }
    
    func wishList(_ index: Int) -> [String] {
        return [wishListDict[index].key, wishListDict[index].value[0], wishListDict[index].value[1]]
    }
    
    var cellPadding: Double {
        Constants.cellLeftPadding
    }

    var numberOfItems: Int {
        wishListDict.count
    }

    func load() {
        view?.prepareCollectionView()
        getWishListData()
    }

    func calculateCellSize(collectionViewWidth: Double) -> (width: Double, height: Double) {
        let cellWidth = collectionViewWidth / 2 - (Constants.cellLeftPadding + Constants.cellRightPadding)
        let bannerImageHeight = cellWidth * Constants.cellBannerImageViewAspectRatio
        return (width: cellWidth, height: Constants.cellDescriptionViewHeight + bannerImageHeight)
    }
}

extension WishListPresenter: WishListInteractorOutput {
    func handleResult(_ result: [String : [String]]) {
        wishListDict = result
    }
}
