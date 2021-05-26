//
//  GameListViewController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import UIKit
import CoreApi

extension GameListViewController {
    fileprivate enum Constants {
        static var cellDescriptionViewHeight: CGFloat = 159
        static var cellBannerImageViewAspectRatio: CGFloat = 201/358

        static let cellLeftPadding: CGFloat = 16
        static let cellRightPadding: CGFloat = 16
    }
}

class GameListViewController: UIViewController {
    let networkManager: NetworkManager<HomeEndpointItem> = NetworkManager()
    private var gamesList: [GameDetail]?
    private var layoutTwoColumns = false
    private var nextPageUrl: String?
    private var shouldFetchNextPage: Bool = false
    
    private var filterList: Filter?
    
    @IBOutlet private weak var rightBarButton: UIBarButtonItem!
    @IBOutlet private weak var gameListCollectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchGameListData(.gamesList)
        prepareCollectionView()
        fetchFilterListData()
    }
    
    private func prepareCollectionView() {
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        gameListCollectionView.dataSource = self
        gameListCollectionView.delegate = self
        
        
        
        gameListCollectionView.register(cellType: GameColumnCollectionViewCell.self)
        gameListCollectionView.register(cellType: GameCollectionViewCell.self)
        filterCollectionView.register(cellType: FilterCollectionViewCell.self)
    }
    

    
    
    fileprivate func fetchFilterListData() {
        networkManager.request(endpoint: .filterList, type: Filter.self) { [weak self] result in
            switch result {
            case .success(let response):
                self?.filterList = response
                self?.filterCollectionView.reloadData()
                break
            case .failure(let error):
                print(error.message)
                break
            }
        }
    }

    
    fileprivate func fetchGameListData(_ endpoint : HomeEndpointItem) {
        networkManager.request(endpoint: endpoint, type: GameListResponse.self) { [weak self] result in
            switch result {
            case .success(let response):
                if self?.shouldFetchNextPage == false {
                    self?.gamesList?.removeAll()
                    self?.gamesList = response.results
                } else {
                    self?.gamesList?.append(contentsOf: response.results!)
                }
                
                self?.nextPageUrl = response.next
                self?.gameListCollectionView.reloadData()
                
                if self?.shouldFetchNextPage == false {
                    self?.gameListCollectionView.setContentOffset(.zero, animated: false)
                }
                
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

extension GameListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterCollectionView {
            return filterList?.count ?? .zero
        } else {
            return gamesList?.count ?? .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filterCollectionView {
            let cell = collectionView.dequeCell(cellType: FilterCollectionViewCell.self, indexPath: indexPath)

            cell.titleLabel.text = filterList?.results?[indexPath.item].name
            return cell
        } else {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            if let filterListData = filterList?.results {
                shouldFetchNextPage = false
                fetchGameListData(.filterItem(query: "\(filterListData[indexPath.item].id!)"))
            }            
        } else {
            if let id = gamesList?[indexPath.item].id {
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let viewController = storyboard.instantiateViewController(identifier: "GameDetailViewController") as! GameDetailViewController
                viewController.fetchGameDetailData(query: "\(id)")
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == filterCollectionView {
            let item = collectionView.cellForItem(at: indexPath)
            if item?.isSelected ?? false {
                shouldFetchNextPage = false
                collectionView.deselectItem(at: indexPath, animated: true)
                fetchGameListData(.gamesList)
            } else {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                return true
            }
            return false
        } else {
            return true
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
        }
           
        return collectionView.frame.size.width
    }
}

extension GameListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == filterCollectionView {
            return .init(width: 50, height: 36)
        }
        
        return .init(width: calculateWidth(collectionView) - (Constants.cellLeftPadding + Constants.cellRightPadding), height: calculateCellHeight())
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            .init(top: .zero, left: Constants.cellLeftPadding, bottom: .zero, right: Constants.cellRightPadding)
    }
}

extension GameListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
//            todo
        } else {
            if indexPath.item == gamesList!.count - 1 {
                shouldFetchNextPage = true
                if let nextPageUrl = nextPageUrl {
                    if let url = URL(string: nextPageUrl) {
                        fetchGameListData(.nextPage(query: url.query ?? ""))
                    }
                
                }
            }
        }
    }
}



