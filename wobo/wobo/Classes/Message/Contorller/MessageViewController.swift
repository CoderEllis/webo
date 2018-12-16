


//
//  MessageViewController.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class MessageViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        visitorView.setupVisitorViewInfo("visitordiscover_image_message", title: "登录后，别人评论你的微博，给你发消息，都会在这里收到通知")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
      

}


// MARK:- 设置UI界面
extension MessageViewController{ 
    fileprivate func setupNavigationBar(){ 
        navigationItem.leftBarButtonItem = UIBarButtonItem("", tatget: self, action: #selector(btnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem("", tatget: self, action: #selector(btnClick))
    }
    
}

// MARK: - 事件监听
extension MessageViewController {
    @objc fileprivate func btnClick() {
        print("左右按钮")
}
}
