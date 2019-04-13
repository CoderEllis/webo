//
//  EmioticonViewCell.swift
//  emoj
//
//  Created by Soul Ai on 3/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

class EmioticonViewCell: UICollectionViewCell {
     lazy var emoticonBtn = UIButton()
    var emoticon : Emoticon? {
        didSet {
            guard let emoticon = emoticon else {
                return
            }//compose_emotion_delete"
            emoticonBtn.setImage(UIImage(contentsOfFile: emoticon.pngPath ?? ""), for: .normal)
            emoticonBtn.setTitle(emoticon.emojiCode, for: .normal)
            
            // 2.设置删除按钮
            if emoticon.isRemove {
                let file = Bundle.main.path(forResource: "Emoticons.bundle/compose_emotion_delete@3x", ofType: "png")!
                emoticonBtn.setImage(UIImage(contentsOfFile: file), for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1.添加子控件
        contentView.addSubview(emoticonBtn)
        emoticonBtn.frame = contentView.bounds
        emoticonBtn.isUserInteractionEnabled = false
        emoticonBtn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }
    
}
