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
//        print(interactivePopGestureRecognizer?.delegate as Any) // 打印查看KVC属性
        /// 全局拖拽手势
        setUpGlobalPan()
        //侧滑手势
//        jubufanhui()
        defaultSetting()
    }
    
    
    /// 全局拖拽手势
    fileprivate func setUpGlobalPan() {
        //全屏滑动返回
        let handler: Selector = NSSelectorFromString("handleNavigationTransition:")
        let globalPan = UIPanGestureRecognizer(target: self.interactivePopGestureRecognizer?.delegate, action: handler)
        globalPan.delegate = self
        view.addGestureRecognizer(globalPan)
        //禁止之前的手势
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //        print(interactivePopGestureRecognizer)
    }
    
    var popDelegate: UIGestureRecognizerDelegate?
    /// 自定义返回按钮保留侧滑返回手势
    func jubufanhui() {
        // 1.保留局部返回手势
        //        interactivePopGestureRecognizer?.delegate = nil
        self.popDelegate = interactivePopGestureRecognizer?.delegate
        self.delegate = self
    }
    
    //全局设置外观
    fileprivate func defaultSetting() {
        //导航栏的背景色与标题设
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red,NSAttributedString.Key.font:UIFont.systemFont(ofSize:17)]
        navigationBar.setBackgroundImage(UIImage(named: "navigationbarBackgroundWhite"), for: UIBarMetrics.default)
        UINavigationBar.appearance().tintColor = UIColor.orange
    }
    
    
    override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
    
    //全局设置外观
//    fileprivate func defaultSetting() {
//        let nvc = UINavigationBar.appearance(whenContainedInInstancesOf: [ELNavigationController.self])
//        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),NSAttributedString.Key.foregroundColor : UIColor.red]
//        nvc.titleTextAttributes = attrs
//        
//        // 设置导航条背景图片
//        navigationBar.setBackgroundImage(UIImage(named: "navigationbarBackgroundWhite"), for: UIBarMetrics.default)
//    }
}

    
   
// MARK: - 全局拖拽手势
extension MainNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return children.count > 1
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count > 0 {
            //跳转时隐藏 tabbar
            viewController.hidesBottomBarWhenPushed = true 
            var title = "返回"
            if children.count == 1 {
                title = children.first?.title ?? "返回"
            } 
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title, imageName: "navigationbar_back_withtext", tatget: self, action: #selector(back))
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    @objc fileprivate func back() {
        popViewController(animated: true)
    }
    

}
        
//自定义UIButton替换导航返回按钮,仍然保持系统边缘返回手势-[UIViewController preferredStatusBarStyle]
extension MainNavigationController: UINavigationControllerDelegate {
// MARK: - UINavigationControllerDelegate
func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // 实现滑动返回功能
        // 清空滑动返回手势的代理就能实现ProdProgressItemListVC
    if viewController == self.viewControllers[0] {//|| viewController is ProdProgressItemListVC { // 可以控制那个控制器不需要局部返回手势
            self.interactivePopGestureRecognizer!.delegate = self.popDelegate
        } else {
            self.interactivePopGestureRecognizer!.delegate = nil
        }
    }
}
    
    
    
    


    
