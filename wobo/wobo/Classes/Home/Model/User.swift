//
//  User.swift
//  wobo
//
//  Created by Soul Ai on 21/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class User: NSObject {
    // MARK:- 属性
    @objc var profile_image_url : String?     // 用户的头像
    @objc var screen_name : String?           // 用户的昵称
    @objc var verified_type : Int = -1       // 用户的认证类型
    @objc var mbrank : Int = 0               // 用户的会员等级
    
    init(dict: [String: Any]) {
        super.init()
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
