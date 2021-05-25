//
//  GamesViewController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import UIKit
import CoreApi

extension GamesViewController {
    fileprivate enum Constants {
        static var cellDescriptionViewHeight: CGFloat = 159
        static var cellBannerImageViewAspectRatio: CGFloat = 201/358

        static let cellLeftPadding: CGFloat = 16
        static let cellRightPadding: CGFloat = 16
    }
}

class GamesViewController: UIViewController {
    let networkManager: NetworkManager<HomeEndpointItem> = NetworkManager()
    private var gamesList: [GameDetail]?
    private var layoutTwoColumns = false
    
    @IBOutlet private weak var rightBarButton: UIBarButtonItem!
    @IBOutlet private weak var gameListCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        prepareCollectionView()
    }
    
    private func prepareCollectionView() {
        gameListCollectionView.dataSource = self
        gameListCollectionView.delegate = self
        
        gameListCollectionView.register(cellType: GameColumnCollectionViewCell.self)
        gameListCollectionView.register(cellType: GameCollectionViewCell.self)
    }

    
    fileprivate func fetchData() {
        networkManager.request(endpoint: .gamesList, type: GameListResponse.self) { [weak self] result in
            switch result {
            case .success(let response):
                self?.gamesList = response.results
                self?.gameListCollectionView.reloadData()
                print(response)
                break
            case .failure(let error):
                print(error.message)
                break
            }
        }
    }
    
    @IBAction func changeLayoutButtonTapped(_ sender: Any) {
        changeLayout()
    }
    
    fileprivate func changeLayout() {
        if layoutTwoColumns {
            rightBarButton.image = UIImage(named: "smallLayoutButton")
            Constants.cellDescriptionViewHeight = 159
            Constants.cellBannerImageViewAspectRatio = 201/358
            layoutTwoColumns = false
        } else {
            rightBarButton.image = UIImage(named: "bigLayoutButton")
            Constants.cellDescriptionViewHeight = 72
            Constants.cellBannerImageViewAspectRatio = 1
            layoutTwoColumns = true
        }
        gameListCollectionView.reloadData()
    }
}

extension GamesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gamesList?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if layoutTwoColumns {
            let cell = collectionView.dequeCell(cellType: GameColumnCollectionViewCell.self, indexPath: indexPath)
            if let gameList = gamesList?[indexPath.item] {
                cell.configure(gamesList: gameList)
            }
            return cell
        } else {
            let cell = collectionView.dequeCell(cellType: GameCollectionViewCell.self, indexPath: indexPath)
            if let gameList = gamesList?[indexPath.item] {
                cell.configure(gamesList: gameList)
            }
            return cell
        }
    }
    
    private func calculateCellHeight() -> CGFloat {
        var collectionViewWidth : CGFloat = 0
        if layoutTwoColumns {
            collectionViewWidth =  gameListCollectionView.frame.size.width / 2
        } else {
            collectionViewWidth =  gameListCollectionView.frame.size.width
        }
        let cellWidth = collectionViewWidth - (Constants.cellLeftPadding + Constants.cellRightPadding)
        let bannerImageHeight = cellWidth * Constants.cellBannerImageViewAspectRatio
        return Constants.cellDescriptionViewHeight + bannerImageHeight
    }

    private func calculateWidth(_ collectionView: UICollectionView) -> CGFloat {
        if layoutTwoColumns {
            return collectionView.frame.size.width / 2
        } else {
            return collectionView.frame.size.width
        }
    }
}

extension GamesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: calculateWidth(collectionView) - (Constants.cellLeftPadding + Constants.cellRightPadding), height: calculateCellHeight())
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: .zero, left: Constants.cellLeftPadding, bottom: .zero, right: Constants.cellRightPadding)
    }
}

//extension GamesViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.item == (gamesList.count - 1), shouldFetchNextPage {
//            fetchWidgets(query: href)
//        }
//    }
//}

