//
//  String+Extension.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 28.05.2021.
//

import Foundation

extension String {
    private static let slugSafeCharacters = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-")

    public func convertedToSlug() -> String? {
        if let latin = self.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
            let urlComponents = latin.components(separatedBy: String.slugSafeCharacters.inverted)
            let result = urlComponents.filter { $0 != "" }.joined(separator: "+")

            if result.count > 0 {
                return result
            }
        }
        return nil
    }
}
