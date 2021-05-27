//
//  WishListViewController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 27.05.2021.
//

import UIKit

protocol ReloadWishListCollectionView {
    func refreshCollectionView()
}

extension WishListViewController {
    fileprivate enum Constants {
        static var cellDescriptionViewHeight: CGFloat = 72
        static var cellBannerImageViewAspectRatio: CGFloat = 1

        static let cellLeftPadding: CGFloat = 16
        static let cellRightPadding: CGFloat = 16
    }
}


class WishListViewController: UIViewController {
    let defaults = UserDefaults.standard
    var delegate : RemoveFromWishListDelegate?
    private var wishListDict: [String:[String]] = [:]

    @IBOutlet weak var wishListCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareCollectionView()
        getWishListData()
        
        if let navigationControllerGame = self.tabBarController?.viewControllers?[0] as? UINavigationController {
            if let wishListVC = navigationControllerGame.viewControllers[0] as? GameListViewController {
                wishListVC.delegate = self
            }
        }
    }
    
    func getWishListData() {
        if let wishListDic = defaults.dictionary(forKey: "WishList") as? [String:[String]]  {
            wishListDict = wishListDic
        }
    }
    
    private func prepareCollectionView() {
        wishListCollectionView.delegate = self
        wishListCollectionView.dataSource = self
        wishListCollectionView.register(cellType: GameColumnCollectionViewCell.self)
    }

}

extension WishListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if wishListDict.count == 0 {
            self.wishListCollectionView.setEmptyMessage("No wishlisted game has been found")
        } else {
            self.wishListCollectionView.restore()
        }
        return wishListDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeCell(cellType: GameColumnCollectionViewCell.self, indexPath: indexPath)
        cell.configure(id: Int(wishListDict[indexPath.item].key) ?? 0, name: wishListDict[indexPath.item].value[0] , image: wishListDict[indexPath.item].value[1])
        cell.wishListButton.tag = indexPath.row
        cell.wishListButton.addTarget(self, action: #selector(wishListButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc func wishListButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        wishListDict.removeValue(forKey: "\(wishListDict[indexPath.row].key)")
        defaults.set(wishListDict, forKey:"WishList")
        wishListCollectionView.reloadData()
        delegate?.refreshCollectionView()
    }
}

extension WishListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.size.width / 2 - (Constants.cellLeftPadding + Constants.cellRightPadding), height: calculateCellHeight())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: .zero, left: Constants.cellLeftPadding, bottom: .zero, right: Constants.cellRightPadding)
    }
    
    private func calculateCellHeight() -> CGFloat {
        let cellWidth = wishListCollectionView.frame.size.width / 2 - (Constants.cellLeftPadding + Constants.cellRightPadding)
        let bannerImageHeight = cellWidth * Constants.cellBannerImageViewAspectRatio
        return Constants.cellDescriptionViewHeight + bannerImageHeight
    }
}

extension WishListViewController: ReloadWishListCollectionView {
    func refreshCollectionView() {
        getWishListData()
        wishListCollectionView.reloadData()
    }
}
