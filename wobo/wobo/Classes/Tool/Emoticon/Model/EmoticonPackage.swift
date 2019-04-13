//
//  EmoticonPackage.swift
//  emoj
//
//  Created by Soul Ai on 3/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

class EmoticonPackage: NSObject {
    var emoticons = [Emoticon]()
    
    init(id: String) {
        super.init()
        
        //最近分组
        if id == "" {
            addEmptyEmoticon(true)
            return
        }
        
        // 2.根据id拼接info.plist的路径
        let plistPath = Bundle.main.path(forResource: "\(id)/info.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        // 3.根据plist文件的路径读取数据 [[String : String]]
        let array = NSArray(contentsOfFile: plistPath) as! [[String: String]]
         // 4.遍历数组
        var index = 0
        for var dic in array {
            if let png = dic["png"] {
                dic["png"] = id + "/" + png
            }
            emoticons.append(Emoticon(dic: dic))
            index += 1
            
            if index == 20 { // 添加删除表情
                emoticons.append(Emoticon(isRemove: true))
                index = 0
            }
        }
        
        // 5.添加空白表情
        addEmptyEmoticon(false)
        
    }
    
    private func addEmptyEmoticon(_ isRecently: Bool) {
        let count = emoticons.count % 21
        if count == 0 && !isRecently {
            return
        }
        for _ in count..<20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
        
        emoticons.append(Emoticon(isRemove: true))
        
    }
    
}
