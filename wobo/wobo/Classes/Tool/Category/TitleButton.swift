//
//  TitleButton.swift
//  wobo
//
//  Created by Soul Ai on 16/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class TitleButton: UIButton {

    // MARK:- 重写init函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setImage(UIImage(named: "navigationbar_arrow_down"), for: .normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.size.width + 5
    }
    
}
