//
//  Date-Extension.swift
//  wobo
//
//  Created by Soul Ai on 21/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import Foundation

extension Date {// class类方法只允许在类内；这里使用“static”声明静态方法
    //类可以使用关键字static class 修饰方法,但是结构体、枚举只能使用关键字static修饰
    //static关键字指定的类方法是不能被子类重写的
    
    ///时间处理
    static func createDateString(_ createAtStr: String) -> String {
        // 1.创建时间格式化对象 Fri Apr 08 11:16:29 +0800 2015
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE MM dd HH:mm:ss Z yyyy"
        fmt.locale = Locale(identifier: "en") 
        
        // 2.将字符串时间,转成Date类型
        guard let createDate = fmt.date(from: createAtStr) else {
            return ""
        }
        
        // 3.创建当前时间
        let nowDate = Date()
        
        // 4.计算创建时间和当前时间的时间差
        let interval = Int(nowDate.timeIntervalSince(createDate))
        
        // 5.对时间间隔处理
        if interval < 60 {
            return "刚刚"
        }
        
        if interval < 60 * 60 {
            return "\(interval / 60)分钟前"
        }
        
        if interval < 60 * 60 * 24 {
            return "\(interval / (60 * 60))小时前"
        }
        
        // 5.4.创建日历对象
        let calendar = Calendar.current
        
        //处理昨天数据: 昨天 12:23
        if calendar.isDateInYesterday(createDate) {
            fmt.dateFormat = "昨天 HH:mm"
            let timeStr = fmt.string(from: createDate)
            return timeStr
        }
        
        //处理一年之内: 02-22 12:22
        let cmps = (calendar as NSCalendar).components(.year, from: createDate, to: nowDate, options: [])
        
        if cmps.year! < 1 {
            fmt.dateFormat = "MM-dd HH:mm"
            let timeStr = fmt.string(from: createDate)
            return timeStr
        }
        
        //超过一年: 2014-02-12 13:22
        fmt.dateFormat = "yyyy-MM-dd HH:mm"
        let timeStr = fmt.string(from: createDate)
        return timeStr
    }
}
