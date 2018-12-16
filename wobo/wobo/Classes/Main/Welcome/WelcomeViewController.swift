
//
//  WelcomeViewController.swift
//  wobo
//
//  Created by Soul Ai on 8/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

class WelcomeViewController: UIViewController {

    lazy var iconview = UIImageView(image: UIImage(named: "avatar_default_big"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgVc()
        
        let profileURLString = UserAccountViewModel.shareIntance.account?.avatar_large
//        loadViewIfNeeded()
        let url = URL(string: profileURLString ?? "")
        iconview.kf.setImage(with: url)
        
        iconview.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-200)
        } 
        
        // Damping : 阻力系数,阻力系数越大,弹动的效果越不明显 0~1
        // initialSpringVelocity : 初始化速度
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4.0, options: [], animations: { 
            self.view.layoutIfNeeded()
        }) { (_) in
            UIApplication.shared.keyWindow?.rootViewController = MainTabBarController()
        }
    }
    
    fileprivate func bgVc() {
        let vc = UIImageView(frame: view.bounds)
        vc.image = UIImage(named: "ad_background")
        view.addSubview(vc)
        view.addSubview(iconview)
        
        //圆形头像
        iconview.layer.cornerRadius = 45
        iconview.layer.masksToBounds = true
        
        iconview.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 90, height: 90))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(+180)
        }     
        view.layoutIfNeeded()
    }

    
}
