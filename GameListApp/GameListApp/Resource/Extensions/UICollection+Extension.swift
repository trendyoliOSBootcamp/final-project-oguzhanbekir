//
//  UICollection+Extension.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 27.05.2021.
//

import UIKit

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = .systemFont(ofSize: 20)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
