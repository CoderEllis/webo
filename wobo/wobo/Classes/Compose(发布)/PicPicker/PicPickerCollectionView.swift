//
//  PicPickerCollectionView.swift
//  wobo
//
//  Created by Soul Ai on 1/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit

private let picPickerCell = "picPickerCell"
private let edgeMargin: CGFloat = 15

class PicPickerCollectionView: UICollectionView {
    var images = [UIImage]() {
        didSet {
            reloadData()
        }
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
//        // 设置collectionView的layou
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemWH = (ScreenWidth - 4 * edgeMargin) / 3
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumLineSpacing = edgeMargin //最少间距
        layout.minimumInteritemSpacing = edgeMargin  //最少行距
        // 设置collectionView的属性  注册 cell "\(PicPickerViewCell.self)"
        //        register(UINib(nibName: "PicPickerViewCell", bundle: nil), forCellWithReuseIdentifier: picPickerCell)
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: picPickerCell)
        // 设置collectionView的内边距
        contentInset = UIEdgeInsets(top: edgeMargin, left: edgeMargin, bottom: 0, right: edgeMargin)
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}

extension PicPickerCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: picPickerCell, for: indexPath)// as! PicPickerViewCell
//        cell.image = indexPath.item <= images.count - 1 ? images[indexPath.item] : nil
        return cell
    }
    
    
}
