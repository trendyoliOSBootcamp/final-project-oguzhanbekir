//
//  MockWishListViewController.swift
//  GameListAppTests
//
//  Created by Oguzhan Bekir on 1.06.2021.
//

@testable import GameListApp

final class MockWishListViewController: WishListInterface {
    var invokedPrepareCollectionView = false
    var invokedPrepareCollectionViewCount = 0
    var invokedReloadData = false
    var invokedReloadDataCount = 0

    func prepareCollectionView() {
        invokedPrepareCollectionView = true
        invokedPrepareCollectionViewCount += 1
    }

     func reloadData() {
         invokedReloadData = true
         invokedReloadDataCount += 1
     }
    
    func calculateCellSize() {
        invokedReloadData = true
        invokedReloadDataCount += 1
    }
}
