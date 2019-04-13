//
//  EmoticonControllerViewController.swift
//  emoj
//
//  Created by Soul Ai on 2/1/2019.
//  Copyright © 2019 Soul Ai. All rights reserved.
//

import UIKit
//import SceneKit

private let EmoticonCell = "EmoticonCell"

class EmoticonController: UIViewController {
    
    var emoticonCallBack: (_ emoticon: Emoticon) -> ()
    
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonCollectionViewLayout())
    private lazy var toolBar = UIToolbar()
    private lazy var manager = EmoticonManager()
    
    // MARK:- 自定义构造函数
    init(emoticonCallBack: @escaping(_ emoticon: Emoticon) -> ()) {
        self.emoticonCallBack = emoticonCallBack //初始化给值 就不用绑定可选类型
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    

}

extension EmoticonController {
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        collectionView.backgroundColor = UIColor.white
        
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        toolBar.translatesAutoresizingMaskIntoConstraints = false
//        let views = ["tBar": toolBar, "cView": collectionView]
//        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tBar]-0-|", options: [], metrics: nil, views: views)
//        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cView]-0-[tBar]-0-|", options: [.alignAllLeft,.alignAllRight], metrics: nil, views: views)
//        view.addConstraints(cons)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(toolBar.snp.top)
        }
        toolBar.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
        }
        
        // 3.准备collectionView
        prepareForCollectionView()
        
        // 4.准备toolBar
        prepareForToolBar()
        
    }
    
    private func prepareForCollectionView() {
        collectionView.register(EmioticonViewCell.classForCoder(), forCellWithReuseIdentifier: EmoticonCell)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func prepareForToolBar() {
        let titles = ["最近", "默认", "emoji", "浪小花"]
        var index = 0
        var tempItems = [UIBarButtonItem]()
        for title in titles {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(itemClick(_:)))
            item.tag = index
            index += 1
            
            tempItems.append(item)
            tempItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            
        }
        tempItems.removeLast()
        toolBar.items = tempItems
        toolBar.tintColor = UIColor.orange
        
    }
    
    @objc private func itemClick(_ item : UIBarButtonItem) {
        print(item.tag)
        let tag = item.tag
        //根据tag获取到当前组
        let indexPath = IndexPath(item: 0, section: tag)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension EmoticonController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return manager.packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let package = manager.packages[section]
        return package.emoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonCell, for: indexPath) as! EmioticonViewCell
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.red : UIColor.blue
        let package = manager.packages[indexPath.section]
        let emoticon = package.emoticons[indexPath.item]
        cell.emoticon = emoticon
        return cell
    }
    
    /// 代理方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1.取出点击的表情
        let package = manager.packages[indexPath.section]
        let emoticon = package.emoticons[indexPath.item]
        // 2.将点击的表情插入最近分组中
        insertRecentlyEmoticon(emoticon)
        
        emoticonCallBack(emoticon)
        
    }
    
    private func insertRecentlyEmoticon(_ emoticon: Emoticon) {
        // 1.如果是空白表情或者删除按钮,不需要插入
        if emoticon.isRemove || emoticon.isEmpty {
            return
        }
        // 2.删除一个表情
        if manager.packages.first!.emoticons.contains(emoticon){ //包含该表情 _重复
            let index = (manager.packages.first?.emoticons.lastIndex(of: emoticon))!
            manager.packages.first?.emoticons.remove(at: index)
        } else {// 原来没有这个表情
            manager.packages.first?.emoticons.remove(at: 19)
        }
        // 3.将emoticon插入最近分组中
        manager.packages.first?.emoticons.insert(emoticon, at: 0)
        
    }
    
}



class EmoticonCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        let itemWH = UIScreen.main.bounds.width / 7
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        let insetMargin = (collectionView!.bounds.height - 3 * itemWH) / 2
        collectionView?.contentInset = UIEdgeInsets(top: insetMargin, left: 0, bottom: insetMargin, right: 0)
    }
}
