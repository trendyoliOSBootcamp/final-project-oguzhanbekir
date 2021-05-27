//
//  GameListViewController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 23.05.2021.
//

import UIKit
import CoreApi

protocol RemoveFromWishListDelegate {
    func refreshCollectionView()
}

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
    let searchController = UISearchController()

    private var gamesList: [GameDetail]?
    private var layoutTwoColumns = false
    private var nextPageUrl: String?
    private var shouldFetchNextPage: Bool = false
    private var filterList: Filter?
    private var searchTextWithFilter = ""
    private var searchText = ""
    private var wishListDict: [String:[String]] = [:]
    let defaults = UserDefaults.standard
    var delegate : ReloadWishListCollectionView?
    
    @IBOutlet private weak var rightBarButton: UIBarButtonItem!
    @IBOutlet private weak var gameListCollectionView: UICollectionView!
    @IBOutlet private weak var filterCollectionView: UICollectionView!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getWishListData()
        fetchGameListData(.gamesList)
        prepareCollectionView()
        fetchFilterListData()
        configureSearchController()
        
        if let navigationController = self.tabBarController?.viewControllers?[1] as? UINavigationController {
            if let wishListVC = navigationController.viewControllers[0] as? WishListViewController {
                wishListVC.delegate = self
            }
        }
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
    
    private func configureSearchController() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .navigationControllerBackgroundGray
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.barStyle = UIBarStyle.black
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func getWishListData() {
        if let wishListData = defaults.dictionary(forKey: "WishList") as? [String:[String]]  {
            wishListDict = wishListData
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 50 {
            view.layoutIfNeeded()
            headerViewHeightConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            view.layoutIfNeeded()
            headerViewHeightConstraint.constant = 68 
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
         }
    }
    
  
}

extension GameListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterCollectionView {
            return filterList?.count ?? .zero
        } else {
            if gamesList?.count == 0 {
                self.gameListCollectionView.setEmptyMessage("No game has been found")
            } else {
                self.gameListCollectionView.restore()
            }
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
                    cell.configure(id: gameList.id ?? 0, name: gameList.name ?? "", image: gameList.backgroundImage ?? "")
                    cell.wishListButton.tag = indexPath.row
                    cell.wishListButton.addTarget(self, action: #selector(wishListButtonTapped), for: .touchUpInside)
                }
                return cell
            } else {
                let cell = collectionView.dequeCell(cellType: GameCollectionViewCell.self, indexPath: indexPath)
                if let gameList = gamesList?[indexPath.item] {
                    cell.configure(gamesList: gameList)
                    cell.addToWishListButton.tag = indexPath.row
                    cell.addToWishListButton.addTarget(self, action: #selector(wishListButtonTapped), for: .touchUpInside)
                }
                return cell
            }
        }
    }
    
    @objc func wishListButtonTapped(sender: UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let id = gamesList?[indexPath.row].id {
            if sender.backgroundColor == UIColor.wishListBackgroundColor {
                wishListDict["\(id)"] = [gamesList?[indexPath.row].name ?? "", gamesList?[indexPath.row].backgroundImage ?? ""]
                defaults.set(wishListDict, forKey:"WishList")
                delegate?.refreshCollectionView()
                sender.backgroundColor = UIColor.appleGreen
            } else {
                wishListDict.removeValue(forKey: "\(id)")
                defaults.set(wishListDict, forKey:"WishList")
                delegate?.refreshCollectionView()
                sender.backgroundColor = UIColor.wishListBackgroundColor
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            if let filterListData = filterList?.results {
                shouldFetchNextPage = false
                searchTextWithFilter = "&parent_platforms=\(filterListData[indexPath.item].id!)"
                if searchText != "" {
                    fetchGameListData(.filterItem(query: "&parent_platforms=\(filterListData[indexPath.item].id!)&search=\(searchText)"))
                } else {
                    fetchGameListData(.filterItem(query: "&parent_platforms=\(filterListData[indexPath.item].id!)"))
                }
            }
        } else {
            if let id = gamesList?[indexPath.item].id {
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let viewController = storyboard.instantiateViewController(identifier: "GameDetailViewController") as! GameDetailViewController
                viewController.fetchGameDetailData(query: "\(id)")
                viewController.delegateGames = self
                for item in wishListDict {
                    if let id = gamesList?[indexPath.item].id {
                        if item.key == "\(id)" {
                            viewController.wishListButton.tintColor = .appleGreen
                        }
                    }
                }
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == filterCollectionView {
            let item = collectionView.cellForItem(at: indexPath)
            if item?.isSelected ?? false {
                shouldFetchNextPage = false
                searchTextWithFilter = ""
                collectionView.deselectItem(at: indexPath, animated: true)
                if searchText != "" {
                    fetchGameListData(.filterItem(query: "&search=\(searchText)"))
                } else {
                    fetchGameListData(.filterItem(query: ""))
                }
                
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
        if collectionView == gameListCollectionView {
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

extension GameListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        guard let text = searchController.searchBar.text else { return }
        searchText = text.convertedToSlug()!
        print(searchText)
        if searchTextWithFilter != "" {
            fetchGameListData(.filterItem(query: "&search=\(text)\(searchTextWithFilter)"))
        } else {
            fetchGameListData(.filterItem(query: "&search=\(searchText)"))
        }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
    }
    
}

extension GameListViewController: RemoveFromWishListDelegate {
    func refreshCollectionView() {
        getWishListData()
        gameListCollectionView.reloadData()
        delegate?.refreshCollectionView()
    }
}



