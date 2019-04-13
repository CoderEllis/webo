//
//  ComposeViewController.swift
//  wobo
//
//  Created by Soul Ai on 28/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

private let picPickerCell = "picPickerCell"

class ComposeViewController: UIViewController,UICollectionViewDelegate {
    var images = [UIImage]() {
        didSet {
            picPickerView.reloadData()
        }
    }
    
    private lazy var titleView = ComposeTitleView()
    private lazy var textView = ComposeTextView()
    private lazy var toolButton = UIToolbar()
    private lazy var picPickerView : UICollectionView = {
        let collectView = UICollectionView(frame: CGRect.zero, collectionViewLayout: ComposeCollectionViewLayout())
        collectView.register(PicPickerViewCell.self, forCellWithReuseIdentifier: picPickerCell)
        return collectView
    }()
    private lazy var emoticonVc = EmoticonController { [weak self] (emoticon) in
        self?.textView.insertEmoticon(emoticon)
        self?.textViewDidChange(self!.textView)
    }
    
    
    /// 工具条底部约束属性
    var toolBottomConstraint:Constraint? //保存约束的属性
    var picHightConstraint:Constraint?
    
    //控制器View加载完成时调⽤用
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        setupNavigationBar()
        SetPicPickerView()
        toolBar()
        
        setUI()
        //监听通知
        setupNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {//进入让键盘弹出
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    deinit {//移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
// initWithCoder -> awakeFromNib -> loadView -> viewDidLoad -> viewWillAppear -> viewWillLayoutSubviews -> viewDidLayoutSubviews -> viewWillLayoutSubviews -> viewDidLayoutSubviews -> viewDidAppear -> viewWillDisappear -> viewDidDisappear -> dealloc -> didReceiveMemoryWarning

    
}

//MARK:- 设置UI界面
extension ComposeViewController { 
    private func setupNavigationBar() {
        // 1.设置左右的item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeItemClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .plain, target: self, action: #selector(sendItemClick))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        // 2.设置标题
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        navigationItem.titleView = titleView
        
        view.addSubview(textView)
        textView.frame = view.bounds
        textView.backgroundColor = UIColor.white
        textView.delegate = self
    }
    
    private func toolBar() {
        var array = [UIBarButtonItem]()
        view.addSubview(toolButton) 
        let imgArr = ["compose_toolbar_picture","compose_mentionbutton_background","compose_trendbutton_background","compose_emoticonbutton_background","compose_keyboardbutton_background"]
        let placeholder = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        array.append(placeholder)
        for i in 0..<5 {
            let item = UIBarButtonItem(imageName: imgArr[i], tag: i + 1000, tatget: self, action: #selector(toolbarClick(_:)))
            array.append(item)
            if i < 4 {
                let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                array.append(space)
            }
        }
        array.append(placeholder)
        toolButton.items = array
//        textView.inputAccessoryView = toolButton
    }
    
    private func SetPicPickerView() {
        view.addSubview(picPickerView)
        picPickerView.backgroundColor = UIColor.lightGray
        picPickerView.dataSource = self
        
    }
    
    private func setupNotifications() {
        // 监听键盘的弹出
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // 监听添加照片的按钮的点击
        NotificationCenter.default.addObserver(self, selector: #selector(addPhotoClick), name: NSNotification.Name(rawValue: PicPickerAddPhotoNote), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removePhotoClick(_:)), name: NSNotification.Name(rawValue: PicPickerRemovePhotoNote), object: nil)
    }

}

// MARK:- 事件监听函数
extension ComposeViewController {
    @objc func closeItemClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sendItemClick() {
        textView.resignFirstResponder()
        // 1.获取发送微博的微博正文
        let statusText = textView.getEmoticonString()
        
        // 2.定义回调的闭包
        let finishedCallback = { (isSuccess : Bool) -> () in
            if !isSuccess {
                SVProgressHUD.showSuccess(withStatus: "发送微博失败")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "发送微博成功")
            self.dismiss(animated: true, completion: nil)
        }
        
        // 3.获取用户选中的图片
        if let image = images.first {
            NetworkTools.shareInstance.sendStatus(statusText, image: image, isSuccess: finishedCallback)
        } else {
            NetworkTools.shareInstance.sendStatus(statusText, isSuccess: finishedCallback)
        }
  
    }
    
    
    //        ("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 550}, {414, 346}}
    //        ("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 896}, {414, 346}}
    
    //        ("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 896}, {414, 288}}
    //        ("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 550}, {414, 346}}        
    
    //        ("UIKeyboardCenterBeginUserInfoKey"): NSPoint: {207, 1040}
    //        ("UIKeyboardCenterBeginUserInfoKey"): NSPoint: {207, 723}
    
    //        ("UIKeyboardCenterEndUserInfoKey"): NSPoint: {207, 723
    //        ("UIKeyboardCenterEndUserInfoKey"): NSPoint: {207, 1069}
    
    //        ("UIKeyboardBoundsUserInfoKey"): NSRect: {{0, 0}, {414, 346}}
    //        ("UIKeyboardAnimationCurveUserInfoKey"): 7, 
    //        ("UIKeyboardIsLocalUserInfoKey"): 1, 
    //        ("UIKeyboardAnimationDurationUserInfoKey"): 0.25   
    
    @objc func keyboardWillChangeFrame(_ note: Notification)  {
//        print(note.userInfo as Any)
        // 1.获取动画执行的时间
        let duration = note.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        // 2.获取键盘最终Y值
        let endFrame = (note.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue 
        
        let y = endFrame.origin.y
        
        // 3.计算工具栏距离底部的间距
        let margin = ScreenHeight - y - bottomSafeAreaHeight
        toolBottomConstraint?.update(offset: -margin)//更新修改约束
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func toolbarClick(_ sender:UIBarButtonItem ) {
        let tag = sender.tag - 1000
        print("tag = \(tag)")
        switch tag {
        case  0:
            // 退出键盘
            textView.resignFirstResponder()
            toolBottomConstraint?.update(offset: 0)
            // 执行动画
            picHightConstraint?.update(offset: ScreenHeight * 0.6)
            UIView.animate(withDuration: 0.25) { 
                self.view.layoutIfNeeded()  
            }
            
        case  1:
            print("0")
        case  2:
            print("0")
        case  3:
            // 退出键盘
            textView.resignFirstResponder()
            textView.inputView = textView.inputView != nil ? nil : emoticonVc.view
            textView.becomeFirstResponder()
            
            
        default:
            print("0")
        }
    }    
    
}

// MARK:- 添加照片和删除照片的事件
extension ComposeViewController {
    @objc private func addPhotoClick() {
        // 1.判断数据源是否可用
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        // 2.创建照片选择控制器
        let ipc = UIImagePickerController()
        // 3.设置照片源
        ipc.sourceType = .photoLibrary
        ipc.delegate = self
        present(ipc, animated: true, completion: nil)
    }
    
    @objc private func removePhotoClick(_ note: Notification) {
        guard let image = note.object as? UIImage else {
            return
        }
        
        guard let index = images.firstIndex(of: image) else {
            return
        }
        images.remove(at: index)
    }
}

// MARK: - 布局UI
extension ComposeViewController {
    func setUI() { 
        let toolBtnH :CGFloat = 44
        
        toolButton.snp.makeConstraints { (make) in
            make.height.equalTo(toolBtnH)
            if #available(iOS 11.0, *) {
                self.toolBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint //保存约束
            } else {
                self.toolBottomConstraint = make.bottom.equalTo(bottomLayoutGuide.snp.top).constraint
            }
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        picPickerView.snp.makeConstraints { (make) in
            self.picHightConstraint = make.height.equalTo(0).constraint
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-toolBtnH)
            } else {
                make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-toolBtnH)
            }
        }
    }
    
}

//scroolview  监听滚动打开Bounce Vertically
// MARK:- UITextView的代理方法
extension ComposeViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.textView.placeHolderLabel.isHidden = textView.hasText
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textView.resignFirstResponder()
        toolBottomConstraint?.update(offset: 0)
    }

}


// MARK: - UICollectionViewDataSource
extension ComposeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: picPickerCell, for: indexPath) as! PicPickerViewCell
        cell.image = indexPath.item <= images.count - 1 ? images[indexPath.item] : nil
        return cell
    }
    
}


// MARK: - UIImagePickerController的代理方法
extension ComposeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        images.append(image)
        picker.dismiss(animated: true, completion: nil)
    }
}


class ComposeCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        let edgeMargin: CGFloat = 15
        
        let itemWH = (ScreenWidth - 4 * edgeMargin) / 3
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumLineSpacing = edgeMargin //最少间距
        minimumInteritemSpacing = edgeMargin  //最少行距
        
        collectionView?.contentInset = UIEdgeInsets(top: edgeMargin, left: edgeMargin, bottom: 0, right: edgeMargin)
    }
    
    
}
