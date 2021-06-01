//
//  FilterCollectionViewCell.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 25.05.2021.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
 
        setupUI()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                containerView.backgroundColor = .white
                titleLabel.textColor = .platformGray
            } else {
                containerView.backgroundColor = .platformGray
                titleLabel.textColor = .white
            }
        }
    }
    
    
    private func setupUI() {
        containerView.backgroundColor = .platformGray
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14)
    }

}
