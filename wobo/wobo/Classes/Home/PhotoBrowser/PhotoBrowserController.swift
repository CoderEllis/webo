//
//  PhotoBrowserController.swift
//  wobo
//
//  Created by Soul Ai on 28/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

private let PhotoBrowserCell = "PhotoBrowserCell"

class PhotoBrowserController: UIViewController {
    /// 图片内容缩张模式
    open var contentMode: UIView.ContentMode = .scaleAspectFill
    
    var indexPath : IndexPath
    var picURLs : [URL]
    
    /// 是否需要遮盖状态栏。默认true
    open var isNeedCoverStatusBar = true
    
    typealias panChangedCallback  = (_ scale: CGFloat) -> Void?
    var originFrameCallback: panChangedCallback
    
    /// 保存原windowLevel
    open var originWindowLevel: UIWindow.Level?
    
    /// 遮盖状态栏。以改变windowLevel的方式遮盖
    /// - parameter cover: true-遮盖；false-不遮盖
    open func coverStatusBar(_ cover: Bool) {
        guard isNeedCoverStatusBar else {
            return
        }
        guard let window = view.window ?? UIApplication.shared.keyWindow else {
            return
        }
        if originWindowLevel == nil {
            originWindowLevel = window.windowLevel
        }
        guard let originLevel = originWindowLevel else {
            return
        }
        window.windowLevel = cover ? .statusBar : originLevel
    }
    
    
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserCollectionViewLayout())
    private lazy var saveBtn = UIButton(bgColor: UIColor.gray, fontSize: 14, title: "保 存")
    
    init(indexPath : IndexPath, picURLs: [URL], back: @escaping panChangedCallback) {
        self.originFrameCallback = back
        self.indexPath = indexPath
        self.picURLs = picURLs
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- 系统回调函数
    override func loadView() {
        super.loadView()
        view.frame.size.width += 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    deinit {
        print("销毁了")
    }
}


// MARK: - UI
extension PhotoBrowserController {
    private func setupUI() {
        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        view.addSubview(collectionView)
        view.addSubview(saveBtn)
        
        collectionView.frame = view.bounds
        saveBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 90, height: 32))
            make.left.equalTo(20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
        
        collectionView.register(PhotoBrowserViewCell.self, forCellWithReuseIdentifier: PhotoBrowserCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        saveBtn.addTarget(self, action: #selector(saveBthClick), for: .touchUpInside)
    }
}


// MARK: - 事件监听
extension PhotoBrowserController {
    
    @objc private func closeBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveBthClick() {
        
        // 1.获取当前正在显示的image
        let cell = collectionView.visibleCells.first as! PhotoBrowserViewCell
        guard let image = cell.imageview.image else {
            return
        }
//  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;        
        //保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: Any) {
        var showInfo = ""
        if error != nil {
            showInfo = "保存失败"
            } else {
            showInfo = "保存成功"
        }
        SVProgressHUD.showInfo(withStatus: showInfo)
    }
    
}



// MARK: - UICollectionViewDataSourc数据源
extension PhotoBrowserController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserCell, for: indexPath) as! PhotoBrowserViewCell
        cell.picURL = picURLs[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoBrowserViewCell else {
            return
        }
        
        cell.imageview.contentMode = contentMode
        // 绑定 Cell 回调事件
        // 拖
        cell.panChangedCallback = { scale in
            // 实测用scale的平方，效果比线性好些
            let alpha = scale * scale
            self.originFrameCallback(alpha)
            // 半透明时重现状态栏，否则遮盖状态栏
            self.coverStatusBar(scale > 0.95)
        }
        // 拖完松手
        cell.panReleasedCallback = { isDown in
            if isDown {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.originFrameCallback(1.0)
            }
        }
        
    }
}

//cell手势代理
extension PhotoBrowserController: PhotoBrowserViewCellDelegate {
    func imageViewClick() {
        closeBtnClick()
    }
}

// MARK:- 遵守AnimatorDismissDelegate
extension PhotoBrowserController: AnimatorDismissDelegate {
    func indexPathForDimissView() -> IndexPath {
        // 1.获取当前正在显示的indexPath
        let cell = collectionView.visibleCells.first!
        
        return collectionView.indexPath(for: cell)!
    }
    
    func imageViewForDimissView() -> UIImageView {
        // 1.创建UIImageView对象
        let imageView = UIImageView()
        let cell = collectionView.visibleCells.first as! PhotoBrowserViewCell
        imageView.frame = cell.imageview.frame
        imageView.image = cell.imageview.image
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    
}

class PhotoBrowserCollectionViewLayout : UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        itemSize = collectionView!.frame.size
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        
        //collectionView的属性 分页 和滚动条
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
    }
}
