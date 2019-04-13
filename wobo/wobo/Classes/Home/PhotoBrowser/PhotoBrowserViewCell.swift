//
//  PhotoBrowserViewCell.swift
//  wobo
//
//  Created by Soul Ai on 5/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit
import Kingfisher

protocol PhotoBrowserViewCellDelegate: NSObjectProtocol {
    func imageViewClick()
}

class PhotoBrowserViewCell: UICollectionViewCell {
    // MARK:- 定义属性
    var picURL : URL? {
        didSet {
            setupContent(picURL)
        }
    }

    weak var delegate : PhotoBrowserViewCellDelegate?
    
    private lazy var scrollView = UIScrollView()
    lazy var imageview = UIImageView()
    private lazy var progressView = ProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("PhotoBrowserViewCell----销毁")
    }
}


// MARK: - UI
extension PhotoBrowserViewCell {
    private func  setupUI() {
        contentView.addSubview(scrollView)
        contentView.addSubview(progressView)
        scrollView.addSubview(imageview)
        
        scrollView.frame = contentView.bounds
        scrollView.frame.size.width -= 20
        
        progressView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        progressView.center = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5)
        progressView.isHidden = false
        progressView.backgroundColor = UIColor.clear
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
        imageview.addGestureRecognizer(tapGes)
        imageview.isUserInteractionEnabled = true //开动用户交互
    }
}

// MARK:- 事件监听
extension PhotoBrowserViewCell {
    @objc private func imageViewClick() {
        delegate?.imageViewClick()
    }
}


// MARK:- 设置cell的内容
extension PhotoBrowserViewCell {
    private func setupContent(_ picUrl: URL?) {
        guard let picURL = picUrl else {
            return
        }
        
        guard let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: picURL.absoluteString) else {
            return
        }
        
        let width = UIScreen.main.bounds.width
        let height = width / image.size.width * image.size.height
        var y : CGFloat = 0
        if height > UIScreen.main.bounds.height {
            y = 0
        } else {
            y = (UIScreen.main.bounds.height - height) * 0.5
        }
        
        imageview.frame = CGRect(x: 0, y: y, width: width, height: height)
        
        progressView.isHidden = false
        imageview.kf.setImage(with: getBigURL(picURL), placeholder: image, options: [], progressBlock: { (current, total) in
            self.progressView.progress = CGFloat(current) / CGFloat(total)
        }) { (_, _, _, _) in
            self.progressView.isHidden = true
        }
        
        scrollView.contentSize = CGSize(width: width, height: height)
    }
    
    //切换大图URL
    private func getBigURL(_ smallURL: URL) -> URL {
        let smallURLString = smallURL.absoluteString
        let bigURLString = smallURLString.replacingOccurrences(of: "thumbnail", with: "bmiddle")
        return URL(string: bigURLString)!
    }
    
}
