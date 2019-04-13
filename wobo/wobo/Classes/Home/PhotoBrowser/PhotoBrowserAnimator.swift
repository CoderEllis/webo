//
//  PhotoBrowserAnimator.swift
//  wobo
//
//  Created by Soul Ai on 6/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

// 面向协议开发
protocol AnimatorPresentedDelegate: NSObjectProtocol {
    func startRect(_ indexPath: IndexPath) -> CGRect
    func endRect(_ indexPath: IndexPath) -> CGRect
    func imageView(_ indexPath: IndexPath) -> UIImageView
}

protocol AnimatorDismissDelegate: NSObjectProtocol {
    func indexPathForDimissView() -> IndexPath
    func imageViewForDimissView() -> UIImageView
}


class PhotoBrowserAnimator: NSObject {
    var isPresented : Bool = false
    weak var presentedDelegate : AnimatorPresentedDelegate?
    var indexPath : IndexPath?
    weak var dismissDelegate : AnimatorDismissDelegate?
    
    deinit {
        print("PhotoBrowserAnimator----销毁")
    }
    
}



extension PhotoBrowserAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {//弹出
        isPresented = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { //消失
        isPresented = false
        return self
    }
    
}

extension PhotoBrowserAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresented ? animationForPresentedView(transitionContext) : animationForDismissView(transitionContext) 
    }
    
    
    ///自定义弹出动画
    func animationForPresentedView(_ transitionContext: UIViewControllerContextTransitioning) {
        // 0.nil值校验
        guard let presentedDelegate = presentedDelegate, let indexPath = indexPath else {
            return
        }
        
        //1.取出弹出的View
        let presentedView = transitionContext.view(forKey: .to)!
        
        // 2.将prensentedView添加到containerView中
        transitionContext.containerView.addSubview(presentedView)
        
        // 3.获取执行动画的imageView
        let startRect = presentedDelegate.startRect(indexPath)
        let imageView = presentedDelegate.imageView(indexPath)
        transitionContext.containerView.addSubview(imageView)
        imageView.frame = startRect
        
        // 4.执行动画
        presentedView.alpha = 0.0
        transitionContext.containerView.backgroundColor = UIColor.black
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            imageView.frame = presentedDelegate.endRect(indexPath)
        }) { (_) in
            imageView.removeFromSuperview()
            presentedView.alpha = 1.0
            transitionContext.containerView.backgroundColor = UIColor.clear
            transitionContext.completeTransition(true) //告诉上下文完成动画
        }
    }
    
    ///自定义消失动画
    func animationForDismissView(_ transitionContext: UIViewControllerContextTransitioning) {
        
        guard let dismissDelegate = dismissDelegate,let presentedDelegate = presentedDelegate else {
            return
        }
        
        let dismissView = transitionContext.view(forKey: .from)
        dismissView?.removeFromSuperview()
        
        // 2.获取执行动画的ImageView
        let imageView = dismissDelegate.imageViewForDimissView()
        transitionContext.containerView.addSubview(imageView)
        let indexPath = dismissDelegate.indexPathForDimissView()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            imageView.frame = presentedDelegate.startRect(indexPath)
        }) { (_) in
            dismissView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
