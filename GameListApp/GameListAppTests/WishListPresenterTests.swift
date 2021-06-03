//
//  WishListPresenterTests.swift
//  GameListAppTests
//
//  Created by Oguzhan Bekir on 1.06.2021.
//

import XCTest
@testable import GameListApp

class WishListPresenterTests: XCTestCase {

    var presenter: WishListPresenter!
    var view: MockWishListViewController!
    var interactor: MockWishListInteractor!
    var data = ["test":["test","test"],
                "test2":["test2","test2"]]
    let indexPath = IndexPath(row: 1, section: 0)
    
    override func setUp() {
        super.setUp()
        view = .init()
        interactor = .init()
        presenter = .init(view: view, interactor: interactor)
    }
    
    func test_load_InvokesRequiredViewMethods() {
        XCTAssertFalse(view.invokedPrepareCollectionView)
        XCTAssertFalse(interactor.invokedFetchWishlisht)
        XCTAssertEqual(presenter.cellPadding, 16)

        presenter.load()
        
        XCTAssertTrue(view.invokedPrepareCollectionView)
        XCTAssertTrue(interactor.invokedFetchWishlisht)
        XCTAssertEqual(presenter.cellPadding, 16)
    }
    
    func test_handleResult_InvokesumberOfItemsMethod() {
        XCTAssertEqual(presenter.numberOfItems, 0)

        presenter.handleResult(data)

        XCTAssertEqual(presenter.numberOfItems, 2)
        
        presenter.defaults.removeObject(forKey: "WishList")
    }
    
    func test_removeFromWishList_InvokesRequiredViewMethod() {
        
        XCTAssertEqual(presenter.numberOfItems, 0)
        XCTAssertFalse(view.invokedReloadData)

        presenter.handleResult(data)
        presenter.removeFromWishList(indexPath.row)

        XCTAssertTrue(view.invokedReloadData)
        XCTAssertEqual(presenter.numberOfItems, 1)
        
        presenter.defaults.removeObject(forKey: "WishList")

    }
    
    func test_calculateCellSize_InvokesSize() {
        let size = presenter.calculateCellSize(collectionViewWidth: 300)
        XCTAssertEqual(size.width, 118)
        XCTAssertEqual(size.height, 190)
        
    }
    
}
