//
//  GameCollectionViewCell.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 24.05.2021.
//

import UIKit
import SDWebImage

class GameCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bannerImageView: UIImageView!
    @IBOutlet private weak var addToWishList: UIView!
    @IBOutlet private weak var platformStackView: UIStackView!
    @IBOutlet private weak var stampView: StampView!
    @IBOutlet private weak var ratingView: StampView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releasedTimeLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var playTimeLabel: UILabel!
    @IBOutlet weak var descriptionContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    private func setupUI() {
        containerView.backgroundColor = .primaryColor
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20)
        playTimeLabel.textColor = .white
        playTimeLabel.font = .systemFont(ofSize: 10)
        releasedTimeLabel.textColor = .white
        releasedTimeLabel.font = .systemFont(ofSize: 10)
        genresLabel.textColor = .white
        genresLabel.font = .systemFont(ofSize: 10)
        descriptionContainerView.backgroundColor = .primaryColor
    }
    
    func configure(gamesList: GameDetail) {
        titleLabel.text = gamesList.name
        
        
        prepareBannerImage(with: gamesList.backgroundImage)
        prepareRating(rating: gamesList.metacritic)
        preparePlatform(platforms: gamesList.platforms)
        prepareDescription(gamesList)
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
            
            ratingView.configure(title: String(rating), titleColor: ratingColor, backgroundColor: .clear, font: .systemFont(ofSize: 10), borderWidth: 0.5, borderColor: ratingColor.cgColor , cornerRadius: 4.0)
        }
    }
    
    private func preparePlatform(platforms: [PlatformElement]?) {
        platformStackView.subviews.forEach({ $0.removeFromSuperview() })

        if let platforms = platforms {
            for (index, platform) in platforms.enumerated() {
                if index < 3 {
                    let customView = StampView(frame: CGRect(x: 0, y: 0,  width: 50, height: 18))
                    customView.configure(title: platform.platform?.name ?? "", backgroundColor: .platformGray, font: .systemFont(ofSize: 10), borderWidth: 0, borderColor: UIColor.platformGray.cgColor, cornerRadius: 0)
                    platformStackView.addArrangedSubview(customView)
                }
            }

            if platforms.count > 3 {
                let customView = StampView(frame: CGRect(x: 0, y: 0,  width: 50, height: 18))
                customView.configure(title: "+\(platforms.count - 3)", backgroundColor: .platformGray, font: .systemFont(ofSize: 10), borderWidth: 0, borderColor: UIColor.platformGray.cgColor, cornerRadius: 0)
                platformStackView.addArrangedSubview(customView)
            }
        }
    }
    
    private func prepareDescription(_ gamesList: GameDetail) {
        genresLabel.text?.removeAll()
        if let playtimeText = gamesList.playtime,
           let relasedText = gamesList.released {
            playTimeLabel.text = "\(playtimeText) hours"

            let date = convertDateFormater(relasedText)
            releasedTimeLabel.text = "\(date)"
        }
        
        if let genres = gamesList.genres {
                let joined = genres.map { $0.name ?? "" }.joined(separator: ", ")
                genresLabel.text? += joined
            
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