//
//  MockWishListInteractor.swift
//  GameListAppTests
//
//  Created by Oguzhan Bekir on 1.06.2021.
//

import Foundation
@testable import GameListApp

final class MockWishListInteractor: WishListInteractorInterface {
    var invokedFetchWishlisht = false
    var invokedFetchWishlishtCount = 0

    func getWishListData() {
        invokedFetchWishlisht = true
        invokedFetchWishlishtCount += 1
    }
}
