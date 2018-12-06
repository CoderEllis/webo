//
//  MainNavigationController.swift
//  wobo
//
//  Created by Soul Ai on 5/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /// 全局拖拽手势
        setUpGlobalPan()
        
    }
}

    
   
// MARK: - 全局拖拽手势
extension MainNavigationController: UIGestureRecognizerDelegate {
    
    /// 全局拖拽手势
    fileprivate func setUpGlobalPan() {
        let handler :Selector = NSSelectorFromString("handleNavigationTransition:")
        let globalPan = UIPanGestureRecognizer(target: self.interactivePopGestureRecognizer?.delegate, action: handler)
        globalPan.delegate = self
        view.addGestureRecognizer(globalPan)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return children.count > 1
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            //隐藏 tabbar
//            viewController.hidesBottomBarWhenPushed = true 
            var title = "返回"
            if children.count == 1 {
                title = children.first?.title ?? "返回"
            } 
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, imageName: "navigationbar_back_withtext", tatget: self, action: #selector(back))
        }
        super .pushViewController(viewController, animated: animated)
    }
    
    @objc fileprivate func back() {
        popViewController(animated: true)
    }
    
    func defaultSetting(){
        
        //导航栏的背景色与标题设
        self.navigationBar.barStyle = UIBarStyle.default
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.isTranslucent = false
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red,NSAttributedString.Key.font:UIFont.systemFont(ofSize:17)]
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }

    
    
}
            
        
//自定义UIButton替换导航返回按钮,仍然保持系统边缘返回手势-[UIViewController preferredStatusBarStyle]
//extension MainNavigationController: UINavigationControllerDelegate {
//    func jubu() {
//         // 1.保留局部返回手势
//        self.interactivePopGestureRecognizer?.delegate = nil
//        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
//        self.delegate = self
//    }
//
//// MARK: - UINavigationControllerDelegate
//func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        // 实现滑动返回功能
//        // 清空滑动返回手势的代理就能实现
//        if viewController == self.viewControllers[0] || viewController is ProdProgressItemListVC { // 可以控制那个控制器不需要局部返回手势
//            self.interactivePopGestureRecognizer!.delegate = self.popDelegate
//        } else {
//            self.interactivePopGestureRecognizer!.delegate = nil
//        }
//    }
//}
    
    
    
    


    
