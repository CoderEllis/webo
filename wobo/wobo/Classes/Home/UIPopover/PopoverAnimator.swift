//
//  PopoverAnimator.swift
//  wobo
//
//  Created by Soul Ai on 16/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class PopoverAnimator: NSObject {
    // MARK:- 对外提供的属性
    var isPresented : Bool = false
    var presentedFrame = CGRect.zero
    var callBack : (( _ presented: Bool) -> ())?  //闭包要初始化明确的值
    
    // MARK:- 自定义构造函数
    // 注意:如果自定义了一个构造函数,但是没有对默认构造函数init()进行重写,那么自定义的构造函数会覆盖默认的init()构造函数
    //@escaping(逃逸闭包):如果一个闭包被作为一个参数传递给一个函数,并且在函数return之后才被唤起执行,那么这个闭包是逃逸闭包.并且这个闭包的参数是可以“逃出”这个函数体外的.
    init(callBack: @escaping (_ presented: Bool) -> ()) {
        self.callBack = callBack
    }
    
    override init() {
        super.init()
    }
}


//UIPresentationController
// MARK:- 自定义转场代理的方法
extension PopoverAnimator: UIViewControllerTransitioningDelegate {
    // 目的:改变弹出View的尺寸
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentation = ELPresentationController(presentedViewController: presented, presenting: presenting)
        presentation.presented_Frame = presentedFrame 
        
        return presentation
    }
    
    // 目的:自定义弹出的动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        callBack!(isPresented)
        return self
    }
    
    // 目的:自定义消失的动画
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        callBack!(isPresented)
        return self
    }
}



// MARK:- 弹出和消失动画代理的方法
extension PopoverAnimator: UIViewControllerAnimatedTransitioning {
    /// 动画执行的时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    /// 获取`转场的上下文`:可以通过转场上下文获取弹出的View和消失的View
    // UITransitionContextFromViewKey : 获取消失的View
    // UITransitionContextToViewKey : 获取弹出的View
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresented ? animationForPresentedView(transitionContext: transitionContext) : animationDismissedView(transitionContext: transitionContext)
    }
    
    
    /// 自定义弹出动画
    fileprivate func animationForPresentedView(transitionContext: UIViewControllerContextTransitioning) {
        // 1.获取弹出的View
        let presentedView = transitionContext.view(forKey: .to)!
        
        // 2.将弹出的View添加到containerView中
        transitionContext.containerView.addSubview(presentedView)
        
        // 3.执行动画
        presentedView.transform = CGAffineTransform(scaleX: 1.0, y: 0)
        presentedView.layer.anchorPoint = CGPoint(x: 0.5, y: 0) //锚点 弹出位置
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            presentedView.transform = CGAffineTransform.identity //恢复最初状态
        }) { (_) in
            // 必须告诉转场上下文你已经完成动画
            transitionContext.completeTransition(true)
        }
    }
    
    /// 自定义消失动画
    fileprivate func animationDismissedView(transitionContext: UIViewControllerContextTransitioning) {
        // 1.获取消失的View
        let dismissView = transitionContext.view(forKey: .from)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            dismissView?.transform = CGAffineTransform(scaleX: 1.0, y: 0.001) //IOS临界值处理的不好 值写小点
        }) { (_) in
            dismissView?.removeFromSuperview()
            // 必须告诉转场上下文你已经完成动画
            transitionContext.completeTransition(true)
        }
        
    }
}
