//
//  StatusViewModel.swift
//  wobo
//
//  Created by Soul Ai on 21/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class StatusViewModel: NSObject {
    
     // MARK:- 定义属性
    var status : Status?
    
    var cellHeight : CGFloat = 0
    
    // MARK:- 对数据处理的属性
    @objc var sourceText : String?        // 处理来源
    @objc var createAtText : String?      // 处理创建时间
    @objc var verifiedImage : UIImage?    // 处理用户认证图标
    @objc var vipImage : UIImage?         // 处理用用户会员等级
    @objc var profileURL : URL?           // 处理用户头像的地址
    @objc var picURLs = [URL]()
    
    init(status: Status) {
        self.status = status
        
        // 1.对来源处理
        if let source = status.source,source != "" {
            // 2.对来源的字符串进行处理.获取起始位置和截取的长度
            //  "<a href=\"http://app.weibo.com/t/feed/1Kd4aA\" rel=\"nofollow\">微博 weibo.com</a>"
            let startIndex = (source as NSString).range(of: ">").location + 1
            let length = (source as NSString).range(of: "</").location - startIndex
            // 2.2.截取字符串
            sourceText = (source as NSString).substring(with: NSRange(location: startIndex, length: length))
        }
        
        // 处理创建时间
        if let created_at = status.created_at {
            createAtText = Date.createDateString(created_at)
        }
        
        // 处理用户认证图标
        let verifiedType = status.user?.verified_type ?? -1
        switch verifiedType {
        case 0:
            verifiedImage = UIImage(named: "avatar_vip")
        case 2, 3, 5:
            verifiedImage = UIImage(named: "avatar_enterprise_vip")
        case 220:
            verifiedImage = UIImage(named: "avatar_grassroot")
        default:
            verifiedImage = nil
        }
        
        // 处理用用户会员等级
        let mbrank = status.user?.mbrank ?? 0
        if mbrank > 0 && mbrank <= 6 {
            vipImage = UIImage(named: "common_icon_membership_level\(mbrank)")
        }
        
        // 处理用户头像的地址
        let profileURLString = status.user?.profile_image_url ?? "" 
        profileURL = URL(string: profileURLString)
        
        //处理配图数据  和转发的配图
        let picURLDicts = status.pic_urls?.count != 0 ? status.pic_urls : status.retweeted_status?.pic_urls
        
        if let picURLDicts = picURLDicts {
            for picURLDict in picURLDicts {
                guard let picURLString = picURLDict["thumbnail_pic"] else {
                    continue //没有就继续
                }
                picURLs.append(URL(string: picURLString)!)
            }
        }
        
    }
}
