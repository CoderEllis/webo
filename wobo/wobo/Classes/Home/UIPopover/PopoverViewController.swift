//
//  PopoverViewController.swift
//  wobo
//
//  Created by Soul Ai on 16/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import SnapKit

class PopoverViewController: UIViewController {

    lazy var bgImageView = UIImageView(image: UIImage(named: "popover_background"))
    lazy var tabView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()

        setPopView()
    }
    
    func setPopView() {
        view.addSubview(bgImageView)
        view.addSubview(tabView)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        bgImageView.frame = view.bounds
        tabView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 10, bottom: 10, right: 10))
        }
    }

}
