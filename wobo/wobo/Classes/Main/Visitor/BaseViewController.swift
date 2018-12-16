//
//  BaseViewController.swift
//  wobo
//
//  Created by Soul Ai on 8/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class BaseViewController: UITableViewController {
    
    lazy var visitorView : ELVisitorView = ELVisitorView()

     // MARK:- 定义变量
    var isLogin : Bool =  UserAccountViewModel.shareIntance.isLogin
    
    override func loadView() {//如果ture 有登录 会调用 super.loadview  false 调用后面的 setupview
        
        isLogin ? super.loadView() : setupVisitorView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItems()
    }
    
    
    
    //根据写入到沙盒的过期时间对比
    func duibiguoqi() {
        //沙盒位置
        var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        accountPath = (accountPath as NSString).appendingPathComponent("accout.plist")
        let account = NSKeyedUnarchiver.unarchiveObject(withFile: accountPath) as? UserAccount
        if let account = account {
            
            if let expiresDate = account.expires_date { //123 125 对比2个值是否降序  升序比他大就是过期
                //orderedAscending 有序升序 orderedSame排序相同 orderedDescending有序下降
                isLogin = expiresDate.compare(Date()) == ComparisonResult.orderedDescending
            }
        }
    }

}


// MARK: - UI
extension BaseViewController {
     /// 设置访客视图
    func setupVisitorView() {
        view = visitorView
        visitorView.registerButton.addTarget(self, action: #selector(registerBtnClick), for: .touchUpInside)
        visitorView.loginButton.addTarget(self, action: #selector(loginBtnClick), for: .touchUpInside)
    }
    
    
    
    /// 设置导航栏左右的Item
    fileprivate func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(registerBtnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(loginBtnClick))
    }
}

//MARK:- 事件监听
extension BaseViewController{
    @objc fileprivate func registerBtnClick() {
        print("registerBtnClick")
    }
    
    
    @objc fileprivate func loginBtnClick() {
        let oauthVc = OAuthViewController()
        // 2.包装导航栏控制器
        present(UINavigationController(rootViewController: oauthVc), animated: true, completion: nil)
    }
}
