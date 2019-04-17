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
    
    //转场蒙版View背景回调
    typealias bgTransitionMask  = (_ scale: CGFloat) -> Void?
    var originFrameCallback: bgTransitionMask
    
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
    
    //UI
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserCollectionViewLayout())
    
    private lazy var saveBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.gray
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitle("保 存", for: .normal)
        btn.addTarget(self, action: #selector(saveBthClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var pageControl:UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isEnabled = false
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.numberOfPages = picURLs.count
        pageControl.currentPage = indexPath.row
        pageControl.backgroundColor = UIColor.clear
        return pageControl
    }()
    
    init(indexPath : IndexPath, picURLs: [URL], back: @escaping bgTransitionMask) {
        self.originFrameCallback = back
        self.indexPath = indexPath
        self.picURLs = picURLs
        super.init(nibName: nil, bundle: nil)
        //设置modal样式 跳转方式
        modalPresentationStyle = .custom
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
        print("浏览器-------销毁了")
    }
}


// MARK: - UI
extension PhotoBrowserController {
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        view.addSubview(collectionView)
        view.addSubview(saveBtn)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.frame = view.bounds
        
        saveBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 60, height: 32))
            make.left.equalTo(20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
        
        if picURLs.count > 2 {
            view.addSubview(pageControl)
            pageControl.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                } else {
                    make.bottom.equalTo(bottomLayoutGuide.snp.top)
                }
            }
        }
       
        
        collectionView.register(PhotoBrowserViewCell.self, forCellWithReuseIdentifier: PhotoBrowserCell)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}


// MARK: - 事件监听
extension PhotoBrowserController {
    
    @objc private func closeBtnClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveBthClick() {
        saveImageTo()
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
//        guard let cell = cell as? PhotoBrowserViewCell else {
//            return
//        }
//        
////        cell.imageview.contentMode = contentMode
//        // 绑定 Cell 回调事件
//        // 拖
//        cell.panChangedCallback = { [weak self] scale in
//            // 实测用scale的平方，效果比线性好些
//            let alpha = scale * scale
//            self?.originFrameCallback(alpha)
//            // 半透明时重现状态栏，否则遮盖状态栏
////            self?.coverStatusBar(scale > 0.95)
//        }
//        // 拖完松手
//        cell.panReleasedCallback = { [weak self] isDown in
//            if isDown {
//                self?.closeBtnClick()
//            } else {
//                self?.originFrameCallback(1.0)
//            }
//        }
        
    }
    
     // 已经停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currentIndex = Int(scrollView.contentOffset.x / ScreenWidth)
            pageControl.currentPage = currentIndex
        }
    }
}


// MARK: - cell手势代理
extension PhotoBrowserController: PhotoBrowserViewCellDelegate {
    
    func panChangedCallback(_ scale: CGFloat) {
        let alpha = scale * scale
        self.originFrameCallback(alpha)
        self.coverStatusBar(scale > 0.95)
    }
    
    func panReleasedCallback(_ isDown: Bool) {
        if isDown {
            self.closeBtnClick()
        } else {
            self.originFrameCallback(1.0)
        }
    }
    
    //单击
    func imageViewOneClick() {
        closeBtnClick()
    }
    //长安手势
    func imageViewLongClick() {
        let actionView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveImageAction = UIAlertAction(title: "保存图片", style: .destructive) { (_) in
            self.saveImageTo()
        }
        let sheetAction = UIAlertAction(title: "分享图片", style: .default) { (_) in
            let cell = self.collectionView.visibleCells.first as! PhotoBrowserViewCell
            guard let image = cell.imageview.image else {
                return
            }
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        actionView.addAction(saveImageAction)
        actionView.addAction(sheetAction)
        actionView.addAction(cancelAction)
        present(actionView, animated: true, completion: nil)
    }
    
    ///保存图片到相册
    func saveImageTo() {
        // 1.获取当前正在显示的image
        let cell = collectionView.visibleCells.first as! PhotoBrowserViewCell
        guard let image = cell.imageview.image else {
            return
        }
        //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;        
        //保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //保存图片到相册私有方法
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: Any) {
        
        if error != nil {
            
            let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            
            let actionView = UIAlertController(title: "保存失败", message: String(format: "请打开 设置-隐私-照片 对“%@”设置为打开", appName ?? "少年,app不取名字的?"), preferredStyle: .alert)
            let saveImageAction = UIAlertAction(title: "前往设置", style: .default) { (_) in
                
                let url = URL(string: "prefs:root=Privacy&path=PHOTOS")
                
                let settingUrl = URL(string: UIApplication.openSettingsURLString)
                
                let shareApplication = UIApplication.shared
                
                if shareApplication.canOpenURL(url!) {
                    shareApplication.openURL(url!)
                    
                }else if shareApplication.canOpenURL(settingUrl!) {
                    shareApplication.openURL(settingUrl!)
                }
            }
            let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            actionView.addAction(saveImageAction)
            actionView.addAction(cancelAction)
            present(actionView, animated: true, completion: nil)
            
        } else {
            SVProgressHUD.showInfo(withStatus: "保存成功")
        }
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
        /// 图片内容缩张模式
        imageView.contentMode = contentMode
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
