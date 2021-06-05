//
//  GameListPresenter.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 3.06.2021.
//

import Foundation

protocol GameListPresenterInterface {
    var numberOfItemsGames: Int { get }
    var numberOfItemFilters: Int { get }
    var cellPadding: Double { get }
    var layoutTwoColumn: Bool { get set}
    func viewDidLoad()
    func getWishListData()
    func getWishlListWithReturn() -> [String:[String]]
    func removeVisitedCell()
    func game(_ index: Int) -> GameDetail?
    func filter(_ index: Int) -> ResultFilter?
    func calculateCellSize(collectionViewWidth: Double) -> (width: Double, height: Double)
    func willDisplay(_ index: Int)
    func addWishlistItem(id: Int, name: String, image: String)
    func removeWishListItem(_ id: Int)
    func fetchGameList(_ endpoint : HomeEndpointItem)
    func filterSelected(_ index: Int)
    func deSelectFilter()
    func searchGame(_ text: String)
    func searchBarCancelButtonTapped()
    func changeLayout()
}

extension GameListPresenter {
    fileprivate enum Constants {
        static var cellDescriptionViewHeight: Double = 159
        static var cellBannerImageViewAspectRatio: Double = 201/358

        static let cellLeftPadding: Double = 16
        static let cellRightPadding: Double = 16
    }
}

final class GameListPresenter {
    weak var view: GameListViewInterface?
    let defaults = UserDefaults.standard
    private let interactor: GameListInteractorInterface
    
    private var gamesList: [GameDetail] = []
    private var firstIsLoading = true
    private var shouldFetchNextPage: Bool = false
    private var nextPageUrl: String?
    private var wishListDict: [String:[String]] = [:]
    private var layoutTwoColumns = false
    private var filterList: Filter?
    private var searchTextWithFilter = ""
    private var searchText = ""

    init(view: GameListViewInterface?,
         interactor: GameListInteractorInterface) {
        self.view = view
        self.interactor = interactor
    }
    
    private func fetchGameListData(_ endpoint : HomeEndpointItem) {
        if firstIsLoading {
            view?.showLoadingView()
        }
        interactor.fetchGameListData(endpoint)
       
    }
    
    private func fetchFilterListData() {
        interactor.fetchFilterListData()
    }
}

extension GameListPresenter: GameListPresenterInterface {
    var cellPadding: Double {
        Constants.cellLeftPadding
    }
    
    var numberOfItemsGames: Int {
        gamesList.count
    }
    
    var numberOfItemFilters: Int {
        filterList?.count ?? 0
    }
    
    func filterSelected(_ index: Int) {
        if let filterListData = filterList?.results {
            shouldFetchNextPage = false
            searchTextWithFilter = "&parent_platforms=\(filterListData[index].id!)"
            if searchText != "" {
                fetchGameListData(.gamesList(query: "&parent_platforms=\(filterListData[index].id!)&search=\(searchText)"))
            } else {
                fetchGameListData(.gamesList(query: "&parent_platforms=\(filterListData[index].id!)"))
            }
        }
    }
    
    func deSelectFilter() {
        shouldFetchNextPage = false
        searchTextWithFilter = ""
        if searchText != "" {
            fetchGameListData(.gamesList(query: "&search=\(searchText)"))
        } else {
            fetchGameListData(.gamesList(query: ""))
        }
    }
 
    func viewDidLoad() {
        getWishListData()
        removeVisitedCell()
        view?.prepareCollectionView()
        fetchGameListData(.gamesList(query: ""))
        fetchFilterListData()
        view?.configureSearchController()
    }
    
    func fetchGameList(_ endpoint : HomeEndpointItem) {
        fetchGameListData(endpoint)
    }
    
    func getWishListData() {
        if let wishListData = defaults.dictionary(forKey: "WishList") as? [String:[String]]  {
            wishListDict = wishListData
        }
    }
    
    func getWishlListWithReturn() -> [String : [String]] {
        wishListDict
    }
    
    func addWishlistItem(id: Int, name: String, image: String) {
        wishListDict["\(id)"] = [name, image]
        defaults.set(wishListDict, forKey: "WishList")
    }
    
    func removeWishListItem(_ id: Int) {
        wishListDict.removeValue(forKey: "\(id)")
        defaults.set(wishListDict, forKey: "WishList")
    }
    
    func removeVisitedCell() {
        defaults.removeObject(forKey: "GameVisited")
    }
    
    func game(_ index: Int) -> GameDetail? {
        gamesList[index]
    }
    
    func filter(_ index: Int) -> ResultFilter? {
        filterList?.results?[index]
    }
    
    func calculateCellSize(collectionViewWidth: Double) -> (width: Double, height: Double) {        
        let collectionWidth = layoutTwoColumns ? collectionViewWidth / 2 : collectionViewWidth

        let cellWidth = collectionWidth - (Constants.cellLeftPadding + Constants.cellRightPadding)
        let bannerImageHeight = cellWidth * Constants.cellBannerImageViewAspectRatio
        return (width: cellWidth, height: Constants.cellDescriptionViewHeight + bannerImageHeight)
    }
    
    func willDisplay(_ index: Int) {
        if index == gamesList.count - 1 {
            shouldFetchNextPage = true
            if let nextPageUrl = nextPageUrl {
                var dict = [String:String]()
                if let url = URL(string: nextPageUrl) {
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                    if let queryItems = components.queryItems {
                        for item in queryItems {
                            dict[item.name] = item.value ?? ""
                        }
                    }
                    fetchGameListData(.gamesList(query: "&page=\(dict["page"] ?? "")"))
                }
            }
        }
    }
    
    func searchGame(_ text: String) {
        searchText = text.convertedToSlug()!
        if !searchTextWithFilter.isEmpty {
            shouldFetchNextPage = false
            fetchGameListData(.gamesList(query: "&search=\(searchText)\(searchTextWithFilter)"))
        } else {
            shouldFetchNextPage = false
            fetchGameListData(.gamesList(query: "&search=\(searchText)"))
        }
    }
    
    func searchBarCancelButtonTapped() {
        searchText = ""
        if !searchTextWithFilter.isEmpty {
            shouldFetchNextPage = false
            fetchGameListData(.gamesList(query: "\(searchTextWithFilter)"))
        } else {
            shouldFetchNextPage = false
            fetchGameListData(.gamesList(query: ""))
        }
    }
    
    var layoutTwoColumn: Bool {
        get {
            layoutTwoColumns
        }
        set {
            layoutTwoColumns = newValue
        }
    }
    
    func changeLayout() {
        if layoutTwoColumns {
            Constants.cellDescriptionViewHeight = 159
            Constants.cellBannerImageViewAspectRatio = 201/358
            layoutTwoColumns = false
        } else {
            Constants.cellDescriptionViewHeight = 72
            Constants.cellBannerImageViewAspectRatio = 1
            layoutTwoColumns = true
        }
        view?.reloadDataGameList()
    }
    
    
}

extension GameListPresenter: GameListInteractorOutput {
    func handleFilterListResult(_ result: FilterResult) {
        switch result {
        
        case .success(let response):
            filterList = response
            view?.reloadDataFilterList()
            break
        case .failure(let error):
            print(error.message)
            break
        }
    }
    
    func handleGameListResult(_ result: GameListResult) {
        if firstIsLoading == true {
            view?.hideLoadingView()
            firstIsLoading = false
         }
         switch result {
         case .success(let response):
            if let games = response.results {
                if shouldFetchNextPage == false {
                   gamesList.removeAll()
                   gamesList = games
                } else {
                   gamesList.append(contentsOf: games)
                }
            }
             nextPageUrl = response.next
             view?.reloadDataGameList()

             break
         case .failure(let error):
             print(error.message)
             break
         }
    }
    
}
