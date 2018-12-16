//
//  UserAccountViewModel.swift
//  wobo
//
//  Created by Soul Ai on 15/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class UserAccountViewModel: NSObject {
    //单例
    static let shareIntance : UserAccountViewModel = UserAccountViewModel()
    
    // MARK:- 定义属性
    var account : UserAccount?
    
    // MARK:- 计算属性
    var accountPath : String { //获取沙盒路径
        let accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        print(accountPath)
        return (accountPath as NSString).appendingPathComponent("accout.plist")
    }
    
    var isLogin : Bool {
        if account == nil {
            return false
        }
        
        guard let expiresDate = account?.expires_date else { // 校验.取出过期日期 : 当前日期
            return false
        }
        //orderedAscending 有序升序 orderedSame排序相同 orderedDescending有序下降
        return expiresDate.compare(Date()) == ComparisonResult.orderedDescending
        
        
    }
    
    override init() {
        super.init()
        // 1.从沙盒中读取中归档的信息
        account = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath) as? UserAccount
//        print("---\(account)")        
    }
    
    
    
    

}
