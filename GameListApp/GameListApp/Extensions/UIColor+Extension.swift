//
//  UIColor+Extension.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 24.05.2021.
//

import UIKit

extension UIColor {
    class var primaryColor: UIColor {
        UIColor(hex: "1d1d1d")
    }
    
    class var warmGray: UIColor {
        UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
    }
    
    class var platformGray: UIColor {
        UIColor(red: 45/255, green: 45/255, blue: 45/255, alpha: 1)
    }

    convenience init(hex: String) {
        var hexString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        guard hexString.count == 6 else {
            self.init(red: 153 / 255.0,
                      green: 153 / 255.0,
                      blue: 153 / 255.0,
                      alpha: 1)
            return
        }
        var rgbValue: UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
}