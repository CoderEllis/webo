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
    lazy var imageview: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
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
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    /// 图片拖动时回调
    open var panChangedCallback: ((_ scale: CGFloat) -> Void)?
    
    /// 图片拖动松手回调。isDown: 是否向下
    open var panReleasedCallback: ((_ isDown: Bool) -> Void)?
}


// MARK: - UI
extension PhotoBrowserViewCell {
    private func  setupUI() {
        contentView.addSubview(scrollView)
        contentView.addSubview(progressView)
        scrollView.addSubview(imageview)
        
        scrollView.frame = contentView.bounds
        scrollView.frame.size.width -= 20
//        scrollView.alpha = 0
        progressView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        progressView.center = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5)
        progressView.isHidden = false
        progressView.backgroundColor = UIColor.clear
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
        imageview.addGestureRecognizer(tapGes)
        imageview.isUserInteractionEnabled = true //开动用户交互
        
        // 拖动手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        // 必须加在图片容器上。不能加在contentView上，否则长图下拉不能触发
        scrollView.addGestureRecognizer(pan)
    }
}

// MARK:- 事件监听
extension PhotoBrowserViewCell {
    @objc private func imageViewClick() {
        delegate?.imageViewClick()
    }
    
    /// 响应拖动
    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard imageview.image != nil else {
            return
        }
        switch pan.state {
        case .began:
            beganFrame = imageview.frame
            beganTouch = pan.location(in: scrollView)
        case .changed:
            let result = panResult(pan)
            imageview.frame = result.0
            panChangedCallback?(result.1)
        case .ended, .cancelled:
            imageview.frame = panResult(pan).0
            let isDown = pan.velocity(in: self).y > 0
            self.panReleasedCallback?(isDown)
            if !isDown {
                resetImageView()
            }
        default:
            resetImageView()
        }
    }
    
    /// 计算拖动时图片应调整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (CGRect, CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: scrollView)
        let currentTouch = pan.location(in: scrollView)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    
}


// MARK: - 计算属性
extension PhotoBrowserViewCell {
    /// 复位ImageView
    private func resetImageView() {
        // 如果图片当前显示的size小于原size，则重置为原size
        let size = fitSize
        let needResetSize = imageview.bounds.size.width < size.width
            || imageview.bounds.size.height < size.height
        UIView.animate(withDuration: 0.25) {
            self.imageview.center = self.resettingCenter
            if needResetSize {
                self.imageview.bounds.size = size
            }
        }
    }
    /// 计算图片复位坐标
    private var resettingCenter: CGPoint {
        let deltaWidth = bounds.width - scrollView.contentSize.width
        let offsetX = deltaWidth > 0 ? deltaWidth * 0.5 : 0
        let deltaHeight = bounds.height - scrollView.contentSize.height
        let offsetY = deltaHeight > 0 ? deltaHeight * 0.5 : 0
        return CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                       y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    /// 计算图片适合的size
    private var fitSize: CGSize {
        guard let image = imageview.image else {
            return CGSize.zero
        }
        var width: CGFloat
        var height: CGFloat
        if scrollView.bounds.width < scrollView.bounds.height {
            // 竖屏
            width = scrollView.bounds.width
            height = (image.size.height / image.size.width) * width
        } else {
            // 横屏
            height = scrollView.bounds.height
            width = (image.size.width / image.size.height) * height
            if width > scrollView.bounds.width {
                width = scrollView.bounds.width
                height = (image.size.height / image.size.width) * width
            }
        }
        return CGSize(width: width, height: height)
    }
    
    /// 计算图片适合的frame
    private var fitFrame: CGRect {
        let size = fitSize
        let y = scrollView.bounds.height > size.height
            ? (scrollView.bounds.height - size.height) * 0.5 : 0
        let x = scrollView.bounds.width > size.width
            ? (scrollView.bounds.width - size.width) * 0.5 : 0
        return CGRect(x: x, y: y, width: size.width, height: size.height)
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

// MARK: - UIGestureRecognizerDelegate
extension PhotoBrowserViewCell: UIGestureRecognizerDelegate {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只响应pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            return false
        }
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        // 向下滑动，如果图片顶部超出可视区域，不响应手势
        if scrollView.contentOffset.y > 0 {
            return false
        }
        // 响应允许范围内的下滑手势
        return true
    }
}
