//
//  HomeViewController.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    fileprivate lazy var titleBtn = TitleButton()
    
    // 注意:在闭包中如果使用当前对象的属性或者调用方法,也需要加self
    // 两个地方需要使用self : 1> 如果在一个函数中出现歧义 2> 在闭包中使用当前对象的属性和方法也需要加self
    fileprivate lazy var popoverAnimator = PopoverAnimator { [weak self] (presented) in
        self?.titleBtn.isSelected = presented //一般在等号右边需要强制解包 因为有可能返回 nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1.没有登录时设置的内容
        visitorView.addRotationAnim()
        
        setupNavigationBar()
    }

}

// MARK:- 设置UI界面
extension HomeViewController{ 
    fileprivate func setupNavigationBar(){ 
        navigationItem.leftBarButtonItem = UIBarButtonItem("navigationbar_friendattention", tatget: self, action: #selector(btnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem("navigationbar_pop", tatget: self, action: #selector(btnClick))
        
        titleBtn.setTitle("coderID", for: .normal)
        titleBtn.setTitleColor(UIColor.black, for: .normal)
        titleBtn.setTitleColor(UIColor.orange, for: .highlighted)
        titleBtn.addTarget(self, action: #selector(titleBtnClick(titleBth:)), for: .touchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    
}


// MARK: - 事件监听
extension HomeViewController {
    @objc fileprivate func btnClick() {
        print("左右按钮")
    }
    
    @objc fileprivate func titleBtnClick(titleBth: TitleButton) {
        let popoverVc = PopoverViewController()
        popoverVc.modalPresentationStyle = .custom
        popoverVc.transitioningDelegate = popoverAnimator
        let width : CGFloat = 180
        let x : CGFloat = ScreenWidth * 0.5 - width * 0.5
        popoverAnimator.presentedFrame = CGRect(x: x, y: navigationHeight, width: width, height: 250)
        present(popoverVc, animated: true, completion: nil)
    }
    
}
