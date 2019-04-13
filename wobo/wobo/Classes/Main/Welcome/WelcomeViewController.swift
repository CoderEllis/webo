
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
    lazy var textLabel = UILabel()
    var topConstraint:Constraint? //保存约束的属性
    override func viewDidLoad() {
        super.viewDidLoad()
        bgVc()
        
        let profileURLString = UserAccountViewModel.shareIntance.account?.avatar_large
//        loadViewIfNeeded()
        let url = URL(string: profileURLString ?? "")
        iconview.kf.setImage(with: url)
        
//        iconview.snp.remakeConstraints { (make) in  //重做约束
//            make.size.equalTo(CGSize(width: 90, height: 90))
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview().offset(-200)
//        }
        
        self.topConstraint?.update(offset: -200) //修改约束
        
        // Damping : 阻力系数,阻力系数越大,弹动的效果越不明显 0~1
        // initialSpringVelocity : 初始化速度
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 4.0, options: [], animations: { 
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
        view.addSubview(textLabel)
        
        //圆形头像
        iconview.layer.cornerRadius = 45
        iconview.layer.masksToBounds = true
        textLabel.text = "欢迎回来"
        textLabel.textAlignment = .center
        
        iconview.snp.makeConstraints { (make) in
            make.size.equalTo(90)//CGSize(width: 90, height: 90)
            make.centerX.equalToSuperview()
            self.topConstraint = make.centerY.equalToSuperview().offset(+180).constraint //保存约束
        }    
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconview.snp.bottom).offset(10)
            make.centerX.equalTo(iconview)
        }
        view.layoutIfNeeded()
    }

    
}
