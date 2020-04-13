//
//  OAuthViewController.swift
//  wobo
//
//  Created by Soul Ai on 14/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController, UIWebViewDelegate{

    fileprivate lazy var webView : UIWebView = {
        let webView = UIWebView(frame: view.bounds)
        return webView
    }()
    
    override func viewDidLoad() {//RGB(r: 232, g: 234, b: 236)
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(r: 232, g: 234, b: 236)

        setUpWebVC()
        setupNavigationBar()
        loadPage()
    }
    

    fileprivate func setUpWebVC() {
        webView.delegate = self
        view.addSubview(webView)
    }

}

// MARK:- 设置UI界面相关
extension OAuthViewController { 
    
    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填充", style: .plain, target: self, action: #selector(fillItemClick))
        title = "登录页面"
    }
    
    fileprivate func loadPage() {
        // 1.获取登录页面的URLString  网址拼接格式 \()
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(app_key)&redirect_uri=\(redirect_uri)"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.loadRequest(request)
//        webView.loadRequest(URLRequest(url: URL(string: "https://www.baidu.com/")!))       
    }
}


// MARK: - 事件监听
extension OAuthViewController {
    @objc fileprivate func closeItemClick() {
        dismiss(animated: true, completion: nil)
        SVProgressHUD.dismiss()
    }
    @objc fileprivate func fillItemClick() {
        // 1.书写js代码 : javascript / java --> 雷锋和雷峰塔
        let jsCode = "document.getElementById('userId').value='15019890173';document.getElementById('passwd').value='Qq5745432';"
        
        webView.stringByEvaluatingJavaScript(from: jsCode)
    }
}


// MARK: - 代理协议
extension OAuthViewController {
    // webView开始加载网页
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    // webView网页加载完成
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    // webView网页加载失败
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.dismiss()
    }
    
    //iOS10下在UIWebView加载的页面,会打印错误日志 WF: _WebFilterIsActive returning  
    //Product => Scheme => Edit Scheme=>Run=>Environment Variables 添加key：OS_ACTIVITY_MODE value：disable
    //或者换成 WKWebView
    //当准备加载某一个页面时,会执行该方法
    //返回为 false 不会加载该页面 true 则相反
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        // 1.获取加载网页的URL
        guard let url = request.url else {
            return true
        }
        // 2.获取url中的字符串
        let urlString = url.absoluteString
        // 3.判断该字符串中是否包含code
        guard urlString.contains("code=") else {
            return true
        }
        // 4.将code截取出来
        let code = urlString.components(separatedBy: "code=").last!
        //https://github.com/CoderEllis?code=d43fd4329ec6795ebad82258ee7919af
//        print(urlString)
//        print(code)
        
        // 5.请求accessToken
        loadAccessToken(code: code)
        return false
    }
}

// MARK: - 请求数据
extension OAuthViewController{ 
    /// 请求AccessToken
    fileprivate func loadAccessToken(code: String) {
        NetworkTools.shareInstance.loadAccessToken(code) { (result, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let accountDict = result else {
                print("没有获取授权后的数据")
                return
            }
            
            let account = UserAccount(dict: accountDict as [String : AnyObject])
            print(account)
            
            self.loadUserInfo(account)
        }
    }   
    
    /// 请求用户信息
    fileprivate func loadUserInfo(_ account: UserAccount) {
        guard let accessToken = account.access_token else {
            return
        }
        guard let uid = account.uid else {
            return
        }
        
        NetworkTools.shareInstance.loadUserInfo(accessToken, uid: uid) { (result, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let userInfoDict = result else {
                return
            }
            // 3.从字典中取出昵称和用户头像地址
            account.screen_name = userInfoDict["screen_name"] as? String
            account.avatar_large = userInfoDict["avatar_large"] as? String
            
            // 4.将account对象保存
            // 4.1.获取沙盒路径 documentDirectory文档目录
//            var accountPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//            accountPath = (accountPath as NSString).appendingPathComponent("accout.plist")
            
            // 4.保存对象到沙盒(写入)
            NSKeyedArchiver.archiveRootObject(account, toFile: UserAccountViewModel.shareIntance.accountPath)
            
            // 5.将account对象设置到单例对象中
            UserAccountViewModel.shareIntance.account = account
            
            // 6.退出当前控制器
            self.dismiss(animated: false, completion: { 
                UIApplication.shared.keyWindow?.rootViewController = WelcomeViewController()
            })
            
        }
        
        
    }
}
