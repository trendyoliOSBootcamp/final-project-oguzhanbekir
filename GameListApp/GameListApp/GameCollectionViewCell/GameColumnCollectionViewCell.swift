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
    @IBOutlet private weak var descriptionContainerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var wishListButton: UIButton!
    
    var wishListDict: [String:[String]] = [:]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        wishListButton.backgroundColor = .wishListBackgroundColor
    }
    
    private func setupUI() {
        containerView.backgroundColor = .primaryColor
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20)
        descriptionContainerView.backgroundColor = .primaryColor
        wishListButton.backgroundColor = .wishListBackgroundColor
    }
    
    func configure(id:Int, name: String, image: String) {
        containerView.backgroundColor = .primaryColor
        titleLabel.text = name
        prepareBannerImage(with: image)
        changeColorOfWishListButton(id)
    }
    
    private func changeColorOfWishListButton(_ id: Int?) {
        if let wishListData = UserDefaults.standard.dictionary(forKey: "WishList") as? [String:[String]]  {
            wishListDict = wishListData
        }
        for item in wishListDict {
            if let id = id {
                if item.key == "\(id)" {
                    wishListButton.backgroundColor = .appleGreen
                }
            }
        }
    }
    
    
    private func prepareBannerImage(with urlString: String?) {
        if let imageUrlString = urlString, let url = URL(string: imageUrlString) {
            bannerImageView.sd_setImage(with: url)
        }
    }

}
