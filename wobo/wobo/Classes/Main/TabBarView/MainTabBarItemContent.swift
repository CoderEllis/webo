//
//  ELTabBarItemContent.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class MainTabBarItemContent: UITabBarController {

    //MARK:- 懒加载属性 发布按钮
    fileprivate lazy var composeBtn = UIButton(imageName: "tabbar_compose_icon_add", bgImageName: "tabbar_compose_button")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setGlobalAppearance()
        setupMainContent()
        setupComposeBtn()
        
        
        //方法二: 中间添加
//        let tabbar = MaintabBar()
//        setValue(tabbar, forKey: "tabBar")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBatItems()
    }
    

}

// MARK:- 设置UI界面
extension MainTabBarItemContent {
    
    fileprivate func setupMainContent() {
        addChild(HomeViewController(), title: "首页", imageName: "tabbar_home")
        addChild(MessageViewController(), title: "消息", imageName: "tabbar_message_center")
        addChild(UIViewController())
        addChild(DiscoverViewController(), title: "发现", imageName: "tabbar_discover")
        addChild(MeViewController(), title: "我", imageName: "tabbar_profile")
    }
    //中间按钮
    fileprivate func setupComposeBtn() {
        tabBar.addSubview(composeBtn)
        composeBtn.center = CGPoint(x: tabBar.center.x, y: tabBar.bounds.size.height * 0.5)
        composeBtn.addTarget(self, action: #selector(composeBtnClick), for: .touchUpInside)
    }
    
    fileprivate func setupTabBatItems() {
        for i in 0..<tabBar.items!.count {
            let item = tabBar.items![i]
            if i == 2 {
                item.isEnabled = false
                return
            }
        }
    }
    
    
    
    fileprivate func addChild(_ childController: UIViewController, title: String, imageName: String) {
        childController.title = title
        print(123)
        // alwaysOriginal 采用图片原生颜色
        childController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        childController.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        addChild(MainNavigationController(rootViewController: childController))
    }
    
    
    
     //全局设置外观
    func setGlobalAppearance() {
        //富文本
        let attrsNormal = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.orange], for: .selected)
//        tabBar.isTranslucent = false//取消 tabbar 半透明
        let tabbar = UITabBar()
        tabbar.backgroundImage = UIImage(named: "tabbar_compose_button")
    }
    
     //部分设置外观
    func setLocalAppearance() {
        let attrsNormal = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 30)]
        UITabBarItem.appearance(whenContainedInInstancesOf: [self.classForCoder as! UIAppearanceContainer.Type]).setTitleTextAttributes(attrsNormal, for: .normal)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
     
}

// MARK: - 中间按钮点击事件
extension MainTabBarItemContent {
    @objc fileprivate func composeBtnClick() {
        let composeVc = textViewViewController()
//        composeVc.view.backgroundColor = UIColor.blue
        present(composeVc, animated: true, completion: nil)
    }
}
