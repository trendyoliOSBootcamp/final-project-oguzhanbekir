//
//  GameDetailViewController.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 26.05.2021.
//

import UIKit
import CoreApi

class GameDetailViewController: UIViewController, LoadingShowable {
    @IBOutlet private weak var bannerImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ratingView: StampView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var playTimeLabel: UILabel!
    @IBOutlet private weak var publishersLabel: UILabel!
    @IBOutlet private weak var visitRedditView: UIView!
    @IBOutlet private weak var visitWebsiteView: UIView!
    @IBOutlet private weak var releasedStackView: UIStackView!
    @IBOutlet private weak var genresStackView: UIStackView!
    @IBOutlet private weak var playTimeStackView: UIStackView!
    @IBOutlet private weak var publishersStackView: UIStackView!
    @IBOutlet private weak var lineOfReleasedView: UIView!
    @IBOutlet private weak var lineOfGenresView: UIView!
    @IBOutlet private weak var lineOfPublishersView: UIView!
    
    let networkManager: NetworkManager<HomeEndpointItem> = NetworkManager()
    private var gameDetailList: GameDetailList?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapToReddit = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        visitRedditView.addGestureRecognizer(tapToReddit)
        let tapToWebsite = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        visitWebsiteView.addGestureRecognizer(tapToWebsite)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let urlString : String?
        switch sender?.view {
        case visitRedditView:
            urlString = gameDetailList?.redditURL
            break
        default:
            urlString = gameDetailList?.website
            break
        }
        guard let url = URL(string: urlString ?? "") else { return }
        UIApplication.shared.open(url)
    }
    
    func fetchGameDetailData(query: String) {
        showLoading()
        networkManager.request(endpoint: .gameDetail(query: query), type: GameDetailList.self) { [weak self] result in
            self?.hideLoading()
            switch result {
            case .success(let response):
                self?.setupView(response: response)
                break
            case .failure(let error):
                print(error.message)
                break
            }
        }
    }
    
    private func setupView(response: GameDetailList) {
        gameDetailList = response
        titleLabel.text = response.name
        descriptionLabel.text = response.descriptionRaw
        prepareBannerImage(with: response.backgroundImage)
        prepareRating(rating: response.metacritic)
        prepareDescription(response)
        prepareRedditView(with: response.redditURL ?? "", view: visitRedditView)
        prepareRedditView(with: response.website ?? "", view: visitWebsiteView)
    }
    
    private func prepareRedditView(with urlString: String, view: UIView) {
        if !urlString.isEmpty {
            view.isHidden = false
        } else {
            view.isHidden = true
        }
    }
    
    private func prepareBannerImage(with urlString: String?) {
        if let imageUrlString = urlString, let url = URL(string: imageUrlString) {
            bannerImageView.sd_setImage(with: url)
        }
    }
    
    private func prepareRating(rating: Int?) {
        let ratingColor : UIColor
        if let rating = rating {
            switch rating {
            case 0...50:
                ratingColor = .red
            case 50...75:
                ratingColor = .yellow
            default:
                ratingColor = .green
            }
            
            ratingView.configure(title: String(rating),
                                 titleColor: ratingColor,
                                 backgroundColor: .clear,
                                 font: .systemFont(ofSize: 10),
                                 borderWidth: 0.5,
                                 borderColor: ratingColor.cgColor ,
                                 cornerRadius: 4.0)
            ratingView.isHidden = false
        } else {
            ratingView.isHidden = true
        }
    }
    
    private func prepareDescription(_ response: GameDetailList?) {
        if let relasedText = response?.released {
            let date = convertDateFormater(relasedText)
            releaseDateLabel.text = "\(date)"
            releasedStackView.isHidden = false
            lineOfReleasedView.isHidden = false
        } else {
            releasedStackView.isHidden = true
            lineOfReleasedView.isHidden = true
        }
        
        if let genres = response?.genres, response?.genres?.count != 0 {
            genresLabel.text = ""
            let joined = genres.map { $0.name! }.joined(separator: ", ")
            genresLabel.text? += joined
            genresStackView.isHidden = false
            lineOfReleasedView.isHidden = false
        } else {
            genresStackView.isHidden = true
            lineOfReleasedView.isHidden = true
        }
        
        if let playtimeText = response?.playtime {
            
            if playtimeText == 0 {
               playTimeStackView.isHidden = true
                lineOfGenresView.isHidden = true
            } else {
                playTimeLabel.text = playtimeText == 1 ? "\(playtimeText) hour" : "\(playtimeText) hours"
                playTimeStackView.isHidden = false
                lineOfGenresView.isHidden = false
            }
        }
        
        if let publishers = response?.publishers, response?.publishers?.count != 0 {
            publishersLabel.text = ""
            let joined = publishers.map { $0.name! }.joined(separator: ", ")
            publishersLabel.text? += joined
            publishersStackView.isHidden = false
            lineOfPublishersView.isHidden = false
        } else {
            publishersStackView.isHidden = true
            lineOfPublishersView.isHidden = true
        }
    }

    func convertDateFormater(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return  dateFormatter.string(from: date!)
    }
}
