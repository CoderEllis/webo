//
//  EmoticonManager.swift
//  emoj
//
//  Created by Soul Ai on 3/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

class EmoticonManager {
    var packages = [EmoticonPackage]()
    
    init() {
        // 1.添加最近表情的包
        packages.append(EmoticonPackage(id: ""))
        packages.append(EmoticonPackage(id: "com.sina.default"))
        packages.append(EmoticonPackage(id: "com.apple.emoji"))
        packages.append(EmoticonPackage(id: "com.sina.lxh"))
        
    }
}
