//
//  ELPresentationController.swift
//  wobo
//
//  Created by Soul Ai on 16/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class ELPresentationController: UIPresentationController {
    // MARK:- 对外提供属性
    var presented_Frame = CGRect.zero
    
    // MARK:- 懒加载属性
    private lazy var coverView = UIView()
    
    // MARK:- 系统回调函数
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = presented_Frame
        
        setupCoverView()
    }
    
}

// MARK:- 设置UI界面相关
extension ELPresentationController { 
    fileprivate func setupCoverView() {
        // 1.添加蒙版
        containerView?.insertSubview(coverView, at: 0)
        // 2.设置蒙版的属性
//        coverView.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        coverView.frame = containerView!.bounds
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverViewClick)))
        
    }
}

extension ELPresentationController {
    @objc fileprivate func coverViewClick() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}
