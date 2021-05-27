//
//  Dictionary+Extension.swift
//  GameListApp
//
//  Created by Oguzhan Bekir on 27.05.2021.
//

import Foundation

extension Dictionary {
    subscript(i: Int) -> (key: Key, value: Value) {
        get {
            return self[index(startIndex, offsetBy: i)]
        }
    }
}
