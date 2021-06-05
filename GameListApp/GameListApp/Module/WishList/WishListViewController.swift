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

protocol WishListInterface: AnyObject {
    func reloadData()
    func prepareCollectionView()
}

final class WishListViewController: UIViewController {
    @IBOutlet weak var wishListCollectionView: UICollectionView!
    var presenter: WishListPresenterInterface!
    var delegate: RemoveFromWishListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.load()
        
        if let navigationControllerGame = self.tabBarController?.viewControllers?[0] as? UINavigationController {
            if let gameListVC = navigationControllerGame.viewControllers[0] as? GameListViewController {
                gameListVC.delegate = self
            }
        }
    }
}

extension WishListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if presenter.numberOfItems == 0 {
            self.wishListCollectionView.setEmptyMessage("No wishlisted game has been found")
        } else {
            self.wishListCollectionView.restore()
        }
        return presenter.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeCell(cellType: GameColumnCollectionViewCell.self, indexPath: indexPath)
        cell.configure(id: Int(presenter.wishList(indexPath.row)[0]) ?? 0, name: presenter.wishList(indexPath.row)[1], image: presenter.wishList(indexPath.row)[2])
        cell.wishListButton.tag = indexPath.row
        cell.wishListButton.addTarget(self, action: #selector(wishListButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc func wishListButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        presenter.removeFromWishList(indexPath.row)
        delegate?.refreshCollectionView()
    }
}

extension WishListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = presenter.calculateCellSize(collectionViewWidth: Double(collectionView.frame.size.width))
        return .init(width: size.width, height: size.height)
                        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: .zero, left: CGFloat(presenter.cellPadding), bottom: .zero, right: CGFloat(presenter.cellPadding))
    }
}

extension WishListViewController: ReloadWishListCollectionView {
    func refreshCollectionView() {
        presenter.load()
        wishListCollectionView.reloadData()
    }
}


extension WishListViewController: WishListInterface {
    func reloadData() {
        wishListCollectionView.reloadData()
    }
    
    func prepareCollectionView() {
        wishListCollectionView.delegate = self
        wishListCollectionView.dataSource = self
        wishListCollectionView.register(cellType: GameColumnCollectionViewCell.self)
    }
}
