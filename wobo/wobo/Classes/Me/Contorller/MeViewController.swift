//
//  MeViewController.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class MeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "??", style: .done, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "!!", style: .done, target: self, action: nil)
        visitorView.setupVisitorViewInfo("visitordiscover_image_profile", title: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
    }
    

    

}


