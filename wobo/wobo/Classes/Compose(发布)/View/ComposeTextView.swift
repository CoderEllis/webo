//
//  ComposeTextView.swift
//  wobo
//
//  Created by Soul Ai on 28/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import SnapKit

class ComposeTextView: UITextView {
    lazy var placeHolderLabel = UILabel()
    
    // awakeFromNib  一般做初始化操作 约束 文字颜色 等等
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
        font = UIFont.systemFont(ofSize: 16)
        alwaysBounceVertical = true //垂直滚动 
    }
    
    required init?(coder aDecoder: NSCoder) {//xib构建控件时 这个一般做添加子控件
        super.init(coder: aDecoder)
        setupUI()
    }
    
}


// MARK: - UI
extension ComposeTextView {
    func setupUI()  {
        addSubview(placeHolderLabel)
        
        placeHolderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(10)
        }
        
        //设置placeholderLabel属性
        placeHolderLabel.textColor = UIColor.red
        placeHolderLabel.font = font
        placeHolderLabel.text = "分享新鲜事..."
        
        //设置内容的内边距
        textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 0, right: 7)
    }
}
