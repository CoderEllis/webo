//
//  Status.swift
//  wobo
//
//  Created by Soul Ai on 20/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.



//     #warning主要用于提醒你或者别人一些工作还没有完成，Xcode模板常使用
//     #warning标记一些你需要替换成自己代码的方法存根(method stubs)。
//     #error主要用于如果你发送一个库，需要其他开发者提供一些数据。

import UIKit

class Status: NSObject {
    /// 属性
    @objc var created_at : String?               // 微博创建时间
//   {
//        didSet {
//            guard let created_at = created_at else {
//                return 
//            }
//            createAtText = Date.createDateString(created_at)
//        } 
//    }
    @objc var source : String?                   // 微博来源
    @objc var text : String?                      // 微博的正文
    @objc var mid : Int = 0                       // 微博的ID
    @objc var user : User?                        // 微博对应的用户
    
    @objc var pic_urls : [[String: String]]?      // 微博的配图
    @objc var retweeted_status : Status?          // 微博对应的转发的微博
    
    /// 自定义构造函数
    init(dict: [String : Any]) {
        super .init()
        setValuesForKeys(dict)
        
        // 1.将用户字典转成用户模型对象
        if let userDict = dict["user"] as? [String: Any] {
            user = User(dict: userDict)
        }
        
        // 2.将转发微博字典转成转发微博模型对象
        if let retweetedStatusDict = dict["retweeted_status"] as? [String: Any] {
            retweeted_status = Status(dict: retweetedStatusDict)
        }
        
        
    }
    
    //避免字典参数中传的参数在类中没有定义相应的属性造成崩溃，重写此方法
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
}
