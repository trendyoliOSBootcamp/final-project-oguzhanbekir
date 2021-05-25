//
//  StampView.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 24.05.2021.
//

import UIKit

final class StampView: NibView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var stampLabel: UILabel!
    
    func configure(title: String,
                   titleColor: UIColor = .white,
                   backgroundColor: UIColor,
                   font: UIFont,
                   borderWidth: CGFloat,
                   borderColor: CGColor,
                   cornerRadius: CGFloat) {
        
        contentView.backgroundColor = backgroundColor
        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.borderColor = borderColor
        contentView.layer.borderWidth = borderWidth
        stampLabel.text = title
        stampLabel.font = font
        stampLabel.textColor = titleColor

        
    }
}
