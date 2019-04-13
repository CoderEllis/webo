//
//  VisitorView.swift
//  wobo
//
//  Created by Soul Ai on 8/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import SnapKit

class ELVisitorView: UIView {

    
    fileprivate lazy var feedImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))// 转盘
    fileprivate lazy var maskImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))// 遮挡
    fileprivate lazy var iconImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    fileprivate lazy var messageLabel : UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor.darkGray
        lab.text = "关注一些人，回这里看看有什么惊喜,关注一些人，回这里看看有什么惊喜"
        lab.numberOfLines = 0
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var loginButton: UIButton = {
        let btn = UIButton(title: "登录", bgImageName: "common_button_white_disable")
        return btn
    }()
 
    lazy var registerButton: UIButton = {
        let btn = UIButton(title: "注册", bgImageName: "common_button_white_disable")
        return btn
    }()
    
    // MARK:- 重写构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        backgroundColor = UIColor.init(rgb: 232)
        addSubview(feedImageView)
        addSubview(maskImageView)
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(loginButton)
        addSubview(registerButton)
        
    }
    
    
    override func layoutSubviews() {
        feedImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        maskImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(feedImageView.snp.bottom)
        }
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(feedImageView).offset(30)
        }
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(feedImageView.snp.bottom).offset(60)
            make.width.equalTo(220)
            make.centerX.equalTo(feedImageView)
        }
        registerButton.snp.makeConstraints { (make) in
            make.left.equalTo(messageLabel)
            make.top.equalTo(feedImageView.snp.bottom).offset(130)
            make.size.equalTo(CGSize(width: 100, height: 35))
        }
        loginButton.snp.makeConstraints { (make) in
            make.size.equalTo(registerButton)
            make.top.equalTo(registerButton)
            make.right.equalTo(messageLabel)
        }
    }
    
    ///自定义函数
    func setupVisitorViewInfo(_ iconName: String, title: String) {
        iconImageView.image = UIImage(named: iconName)
        messageLabel.text = title
        feedImageView.isHidden = true
    }
    
    // 设置圆圈动画
    func addRotationAnim() { 
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.toValue = Double.pi * 2
        anim.duration = 20  // 设置时长
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false // 当切换控制器 或者程序退到后台 默认动画会被移除
        feedImageView.layer.add(anim, forKey: nil)
    }
    
}

