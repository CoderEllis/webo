//
//  ELTabBarItemContent.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultSetting()
        setupMainContent()
        
        
        // 中间按钮添加
        let tabbar = MaintabBar()
        setValue(tabbar, forKey: "tabBar")

        tabbar.composeBtn.addTarget(self, action: #selector(composeBtnClick), for: .touchUpInside)
    }

    

}

// MARK:- 设置UI界面
extension MainTabBarController {
    
    fileprivate func setupMainContent() {
        addChild(HomeViewController(), title: "首页", imageName: "tabbar_home")
        addChild(MessageViewController(), title: "消息", imageName: "tabbar_message_center")
        addChild(DiscoverViewController(), title: "发现", imageName: "tabbar_discover")
        addChild(MeViewController(), title: "我", imageName: "tabbar_profile")
    }
    
    fileprivate func addChild(_ childController: UIViewController, title: String, imageName: String) {
        childController.title = title
        
        // alwaysOriginal 采用图片原生颜色
        childController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        addChild(MainNavigationController(rootViewController: childController))
    }
    
    
    
     //全局设置外观defaultSetting
    fileprivate func defaultSetting() {
        //富文本
        let attrsNormal = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.orange], for: .selected)
    }
    
     //部分设置外观
    func setLocalAppearance() {
        let attrsNormal = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 30)]
        UITabBarItem.appearance(whenContainedInInstancesOf:  [self.classForCoder as! UIAppearanceContainer.Type]).setTitleTextAttributes(attrsNormal, for: .normal)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
     
}


// MARK: - 点击事件
extension MainTabBarController {
    /// 中间的 view
    @objc func composeBtnClick() {
        let composeVc = ComposeViewController()
        present(UINavigationController(rootViewController: composeVc), animated: true, completion: nil)
    }
}
