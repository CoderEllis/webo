//
//  MaintabBar.swift
//  wobo
//
//  Created by Soul Ai on 5/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class MaintabBar: UITabBar {
    fileprivate lazy var composeBtn = UIButton(imageName: "tabbar_compose_icon_add", bgImageName: "tabbar_compose_button")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        composeBtn.addTarget(self, action: #selector(composeBtnClick), for: .touchUpInside)
        addSubview(composeBtn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //        tabBar.isTranslucent = false//取消半透明
    //        tabBar.backgroundImage = UIImage(named: "tabbar-light")
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = CGFloat((items?.count)!)
        let width = bounds.width / (count + 1)
        var index : CGFloat = 0
        for view in subviews {
            if view.isKind(of: NSClassFromString("UITabBarButton")!) {
                view.frame = CGRect(x: index * width, y: 0, width: width, height: 49)
                index += 1
                if index == 2 {
                    composeBtn.frame.size = CGSize(width: (composeBtn.currentBackgroundImage?.size.width)!, height: (composeBtn.currentBackgroundImage?.size.height)!)
                    index += 1
                }
            }
        }
        composeBtn.center = CGPoint(x: frame.width * 0.5, y: 49 * 0.5)
    }

     /// 如果按钮凸出的话,重写hitTest方法 让凸出的部分也响应点击
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        /// 判断是否为根控制器
        if self.isHidden {
            /// tabbar隐藏 不在主页 系统处理
            return super.hitTest(point, with: event)
            
        }else{
            /// 将单钱触摸点转换到按钮上生成新的点
            let onButton = self.convert(point, to: composeBtn)
            /// 判断新的点是否在按钮上
            if composeBtn.point(inside: onButton, with: event){
                return composeBtn
            }else{
                /// 不在按钮上 系统处理
                return super.hitTest(point, with: event)
            }
        }
    }
    
    
    /// 中间的 view
    @objc fileprivate func composeBtnClick() { 
        let composeVc = ELVisitorViewController()
        composeVc.view.backgroundColor = UIColor.magenta
        window?.rootViewController?.present(composeVc, animated: true, completion: nil)
        
    }
}
