//
//  PicPickerViewCell.swift
//  wobo
//
//  Created by Soul Ai on 1/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit
import SnapKit

class PicPickerViewCell: UICollectionViewCell {

    private lazy var imageView = UIImageView()
    private lazy var addPhotoBth = UIButton(type: .custom)
    private lazy var deleteBtn = UIButton(type: .custom)
    
    var image : UIImage? {
        didSet {
            if image != nil {
                imageView.image = image
                addPhotoBth.isUserInteractionEnabled = false //用户交互 取消
                deleteBtn.isHidden = false
            } else {
                imageView.image = nil 
                addPhotoBth.isUserInteractionEnabled = true
                deleteBtn.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUIcell()
        deleteBtn.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutView()
    }
    
    
    private func setUIcell()  {
        addSubview(addPhotoBth)
        addSubview(imageView)
        addSubview(deleteBtn)
        deleteBtn.setImage(UIImage(named: "compose_photo_close"), for: .normal)
        addPhotoBth.setBackgroundImage(UIImage(named: "compose_pic_add"), for: .normal)
        addPhotoBth.setBackgroundImage(UIImage(named: "compose_pic_add_highlighted"), for: .highlighted)
        addPhotoBth.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
    }
    
    
    
}

extension PicPickerViewCell {
    private func layoutView() {
        deleteBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.size.equalTo(24)
        }
        imageView.frame = self.bounds
        addPhotoBth.frame = self.bounds
//        imageView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//        }
//        addPhotoBth.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//        }
        
    }
}

extension PicPickerViewCell {
    @objc private func addPhoto() { // 多重传递 用通知 Notification
        NotificationCenter.default.post(name: NSNotification.Name(PicPickerAddPhotoNote), object: nil)
    }
    
    @objc private func deletePhoto() {
        NotificationCenter.default.post(name: NSNotification.Name(PicPickerRemovePhotoNote), object: imageView.image)
    }
}
