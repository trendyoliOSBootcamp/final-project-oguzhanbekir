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

protocol GameListViewInterface: AnyObject {
    func showLoadingView()
    func hideLoadingView()
    func reloadDataGameList()
    func reloadDataFilterList()
    func prepareCollectionView()
    func configureSearchController()
    func changeLayout()
}

final class GameListViewController: UIViewController, LoadingShowable {
    @IBOutlet private weak var rightBarButton: UIBarButtonItem!
    @IBOutlet private weak var gameListCollectionView: UICollectionView!
    @IBOutlet private weak var filterCollectionView: UICollectionView!
    @IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController()
    var delegate : ReloadWishListCollectionView?
    var presenter: GameListPresenterInterface!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()
        
        if let navigationController = self.tabBarController?.viewControllers?[1] as? UINavigationController {
            if let wishListVC = navigationController.viewControllers[0] as? WishListViewController {
                wishListVC.delegate = self
            }
        }
    }
    

    @IBAction func changeLayoutButtonTapped(_ sender: Any) {
        changeLayout()
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
            return presenter.numberOfItemFilters
        } else {
            if presenter.numberOfItemsGames == 0 {
                self.gameListCollectionView.setEmptyMessage("No game has been found")
            } else {
                self.gameListCollectionView.restore()
            }
            return presenter.numberOfItemsGames
        }
    }
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filterCollectionView {
            let cell = collectionView.dequeCell(cellType: FilterCollectionViewCell.self, indexPath: indexPath)
            cell.titleLabel.text = presenter.filter(indexPath.item)?.name
            return cell
        } else {
            if presenter.layoutTwoColumn {
                let cell = collectionView.dequeCell(cellType: GameColumnCollectionViewCell.self, indexPath: indexPath)
                if let gameList = presenter.game(indexPath.row) {
                    cell.configure(id: gameList.id ?? 0, name: gameList.name ?? "", image: gameList.backgroundImage ?? "")
                    cell.wishListButton.tag = indexPath.row
                    cell.wishListButton.addTarget(self, action: #selector(wishListButtonTapped), for: .touchUpInside)
                }
                return cell
            } else {
                let cell = collectionView.dequeCell(cellType: GameCollectionViewCell.self, indexPath: indexPath)
                if let gameList = presenter.game(indexPath.row)  {
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
        if let game = presenter.game(indexPath.row) {
            if sender.backgroundColor == UIColor.wishListBackgroundColor {
                presenter.addWishlistItem(id: game.id ?? 0, name: game.name ?? "", image: game.backgroundImage ?? "")
                delegate?.refreshCollectionView()
                sender.backgroundColor = UIColor.appleGreen
            } else {
                presenter.removeWishListItem(game.id ?? 0)
                delegate?.refreshCollectionView()
                sender.backgroundColor = UIColor.wishListBackgroundColor
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == filterCollectionView {
            presenter.filterSelected(indexPath.row)
        } else {
            if let id = presenter.game(indexPath.item)?.id  {
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                let viewController = storyboard.instantiateViewController(identifier: "GameDetailViewController") as! GameDetailViewController
                viewController.fetchGameDetailData(query: "\(id)")
                viewController.delegateGames = self
                for item in presenter.getWishlListWithReturn() {
                    if item.key == "\(id)" {
                       viewController.wishListButton.tintColor = .appleGreen
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
                presenter.deSelectFilter()
                collectionView.deselectItem(at: indexPath, animated: true)
            } else {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                return true
            }
            return false
        } else {
            return true
        }
    }

}

extension GameListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == filterCollectionView {
            return .init(width: 50, height: 36)
        }
    
        let size = presenter.calculateCellSize(collectionViewWidth: Double(collectionView.frame.size.width))
            return .init(width: size.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            .init(top: .zero, left: CGFloat(presenter.cellPadding), bottom: .zero, right: CGFloat(presenter.cellPadding))
    }
    
}

extension GameListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == gameListCollectionView {
            presenter.willDisplay(indexPath.item)
        }
    }
}

extension GameListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        guard let text = searchController.searchBar.text else { return }
        presenter.searchGame(text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.searchBarCancelButtonTapped()
    }
    
}

extension GameListViewController: RemoveFromWishListDelegate {
    func refreshCollectionView() {
        presenter.getWishListData()
        gameListCollectionView.reloadData()
        delegate?.refreshCollectionView()
    }
}

extension GameListViewController: GameListViewInterface {
    func changeLayout() {
        if presenter.layoutTwoColumn {
            presenter.changeLayout()
            rightBarButton.image = UIImage(named: "smallLayoutButton")
        } else {
            presenter.changeLayout()
            rightBarButton.image = UIImage(named: "bigLayoutButton")
        }
    }
    
    func showLoadingView() {
        showLoading()
    }
    
    func hideLoadingView() {
        hideLoading()
    }
    
    
    func reloadDataGameList() {
        gameListCollectionView.reloadData()
    }
    
    func reloadDataFilterList() {
        filterCollectionView.reloadData()
    }
    
    func prepareCollectionView() {
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        gameListCollectionView.dataSource = self
        gameListCollectionView.delegate = self
        
        gameListCollectionView.register(cellType: GameColumnCollectionViewCell.self)
        gameListCollectionView.register(cellType: GameCollectionViewCell.self)
        filterCollectionView.register(cellType: FilterCollectionViewCell.self)
    }
    
    func configureSearchController() {
        searchController.searchBar.delegate = self
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .navigationControllerBackgroundGray
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.barStyle = UIBarStyle.black
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController

//        definesPresentationContext = false
        
    }
    
}


