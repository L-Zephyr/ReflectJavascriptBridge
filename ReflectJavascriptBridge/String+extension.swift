//
//  String+extension.swift
//  Reflect
//
//  Created by LZephyr on 2017/1/20.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

extension String {
    /// 首字母大写
    internal func capitalizedFirst() -> String {
        if self.characters.count == 0 {
            return self
        }
        
        var str = self
        let firstCharacter = str.characters.first
        return String(firstCharacter!).uppercased() + String(str.characters.dropFirst())
    }
}
