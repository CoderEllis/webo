//
//  PicViewCell.swift
//  wobo
//
//  Created by Soul Ai on 23/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import Kingfisher

class PicViewCell: UICollectionViewCell {

    lazy var iconView = UIImageView()
    
    var picURL : URL? {
        didSet {
            guard let picURL = picURL else {
                return
            }
            iconView.kf.setImage(with: picURL, placeholder: UIImage(named: "empty_picture"), options: [], progressBlock: nil, completionHandler: nil)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setIconView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    func setIconView() {
        contentView.addSubview(iconView)
        iconView.frame = contentView.bounds
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
    }
    
}
