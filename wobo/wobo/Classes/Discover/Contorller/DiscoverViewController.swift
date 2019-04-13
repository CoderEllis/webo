//
//  DiscoverViewController.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class DiscoverViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "没有", style: .done, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发现", style: .done, target: self, action: nil)
        
        visitorView.setupVisitorViewInfo("visitordiscover_image_message", title: "登录后，能发现那些逗比做了些什么呢")
    }


}
