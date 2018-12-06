//
//  UIBarButtonItem-Extension.swift
//  wobo
//
//  Created by Soul Ai on 5/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    ///返回按钮
    convenience init(title: String,imageName: String, tatget:Any? ,action: Selector) {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .normal)
        btn.setTitleColor(UIColor.orange, for: .highlighted)
        btn.setImage(UIImage(named: imageName), for: .normal)
        btn.setImage(UIImage(named: imageName  + "_highlighted"), for: .highlighted)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        btn.addTarget(tatget, action: action, for: .touchUpInside)
        btn.contentHorizontalAlignment = .left
        btn.sizeToFit()
        self.init(customView: btn)
    }
}
