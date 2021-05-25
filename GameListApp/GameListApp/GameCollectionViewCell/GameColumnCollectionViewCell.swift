//
//  GameColumnCollectionViewCell.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 25.05.2021.
//

import UIKit

class GameColumnCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var bannerImageView: UIImageView!
    @IBOutlet private weak var addToWishlistView: UIView!
    @IBOutlet private weak var descriptionContainerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
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
        descriptionContainerView.backgroundColor = .primaryColor
    }
    
    func configure(gamesList: GameDetail) {
        titleLabel.text = gamesList.name
        prepareBannerImage(with: gamesList.backgroundImage)
    }
    
    private func prepareBannerImage(with urlString: String?) {
        if let imageUrlString = urlString, let url = URL(string: imageUrlString) {
            bannerImageView.sd_setImage(with: url)
        }
    }

}
