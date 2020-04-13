//
//  PicCollectionView.swift
//  wobo
//
//  Created by Soul Ai on 22/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import Kingfisher

class PicCollectionView: UICollectionView {
    // MARK:- 定义属性
    var picURLs = [URL]() {
        didSet {
            self.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
        dataSource = self
    }
        
}


// MARK:- collectionView的数据源方法
extension PicCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PicCell", for: indexPath) as! PicViewCell
//        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.red : UIColor.green
        cell.picURL = picURLs[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //传递通知的参数
        let userInfo = [ShowPhotoBrowserIndexKey : indexPath, ShowPhotoBrowserUrlsKey: picURLs] as [String : Any]
        //发出通知
        NotificationCenter.default.post(name: NSNotification.Name(ShowPhotoBrowserNote), object: self, userInfo: userInfo)
    }
    
    
}


// MARK: - 动画协议
extension PicCollectionView : AnimatorPresentedDelegate {
    func startRect(_ indexPath: IndexPath) -> CGRect {
        let cell = self.cellForItem(at: indexPath)!
        // 2.获取cell的framec
        let startFrame = self.convert(cell.frame, to: UIApplication.shared.keyWindow)
        
        return startFrame
    }
    
    func endRect(_ indexPath: IndexPath) -> CGRect {
         // 1.获取该位置的image对象
        let picURL = picURLs[indexPath.item]
        guard let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: picURL.absoluteString) else {
            return CGRect.zero
        }
        
        // 2.计算结束后的frame
        let w = UIScreen.main.bounds.width
        let h = w / image.size.width * image.size.height
        var y : CGFloat = 0
        if h > UIScreen.main.bounds.height {
            y = 0
        } else {
            y = (UIScreen.main.bounds.height - h) * 0.5
        }
        
        return CGRect(x: 0, y: y, width: w, height: h)
        
    }
    
    func imageView(_ indexPath: IndexPath) -> UIImageView {
        // 1.创建UIImageView对象
        let imageView = UIImageView()
        let picURL = picURLs[indexPath.item]
        let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: picURL.absoluteString)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    
}
