//
//  HomeViewController.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh

private let HomeCellID = "HomeCellID1"

class HomeViewController: BaseViewController {

    private lazy var titleBtn = TitleButton()
    private lazy var tipLabel = UILabel()
    
    
    
    // 注意:在闭包中如果使用当前对象的属性或者调用方法,也需要加self
    // 两个地方需要使用self : 1> 如果在一个函数中出现歧义 2> 在闭包中使用当前对象的属性和方法也需要加self
    private lazy var popoverAnimator = PopoverAnimator { [weak self] (presented) in
        self?.titleBtn.isSelected = presented //一般在等号右边需要强制解包 因为有可能返回 nil
        //HomeViewController -> popoverAnimator类 -> 闭包-> HomeViewController.titleBtn  循环引用
    }
    
    //懒加载数组
    private lazy var viewModels  = [StatusViewModel]()
    private lazy var photoBrowserAnimator = PhotoBrowserAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1.没有登录时设置的内容
        visitorView.addRotationAnim()
        if !isLogin{
            return
        }
        
        setupNavigationBar()
        //上下拉刷新
        setupHeaderView()
        setupFooterView()
        
        //5.提示 label
        setupTipLabel()
        tableView.register(UINib(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: HomeCellID)
        
        // 3.设置估算高度
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // 6.监听通知
        setupNatifications()
        
    }

}

// MARK:- 设置UI界面
extension HomeViewController{ 
    fileprivate func setupNavigationBar(){ 
        navigationItem.leftBarButtonItem = UIBarButtonItem("navigationbar_friendattention", tatget: self, action: #selector(btnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem("navigationbar_pop", tatget: self, action: #selector(btnClick))
        
        titleBtn.setTitle("coderID", for: .normal)
        titleBtn.setTitleColor(UIColor.black, for: .normal)
        titleBtn.setTitleColor(UIColor.orange, for: .highlighted)
        titleBtn.addTarget(self, action: #selector(titleBtnClick(titleBth:)), for: .touchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    private func setupHeaderView() {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewStatuses))
        // 2.设置header的属性
        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("释放更新", for: .pulling)
        header?.setTitle("加载中...", for: .refreshing)
        // 3.设置tableView的header
        tableView.mj_header = header
        // 4.进入刷新状态
        tableView.mj_header.beginRefreshing()
    }
    
    private func setupFooterView() {
        tableView.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreStatuses))
    }
    
    private func setupTipLabel() {
        // 1.将tipLabel添加父控件中
        navigationController?.navigationBar.insertSubview(tipLabel, at: 0)
        tipLabel.frame = CGRect(x: 0, y: 20, width: ScreenWidth, height: 32)
        tipLabel.backgroundColor = UIColor.orange
        tipLabel.textColor = UIColor.white
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textAlignment = .center
        tipLabel.isHidden = true
    }
    
    private func setupNatifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showPhotoBrowser(_:)), name: NSNotification.Name(rawValue: ShowPhotoBrowserNote), object: nil)
    }
    
}


// MARK: - 事件监听
extension HomeViewController {
    @objc private func btnClick() {
        print("左右按钮")
    }
    
    ///nav的弹窗view
    @objc private func titleBtnClick(titleBth: TitleButton) {
        let popoverVc = PopoverViewController()
        popoverVc.modalPresentationStyle = .custom
        popoverVc.transitioningDelegate = popoverAnimator
        let width : CGFloat = 180
        let x : CGFloat = ScreenWidth * 0.5 - width * 0.5
        popoverAnimator.presentedFrame = CGRect(x: x, y: navigationHeight, width: width, height: 250)
        present(popoverVc, animated: true, completion: nil)
    }
    
    ///图片浏览通知事件
    @objc private func showPhotoBrowser(_ note: Notification) {
//        print(note.userInfo)
         // 0.取出数据
        let indexPath = note.userInfo?[ShowPhotoBrowserIndexKey] as! IndexPath
        let picURLs = note.userInfo?[ShowPhotoBrowserUrlsKey] as! [URL]
        let object = note.object as! PicCollectionView
        
        
        let photoBrowserVc = PhotoBrowserController(indexPath: indexPath, picURLs: picURLs)
        // 2.设置modal样式 跳转方式
        photoBrowserVc.modalPresentationStyle = .custom
        
        // 3.设置转场的代理
        photoBrowserVc.transitioningDelegate = photoBrowserAnimator
        
        // 4.设置动画的代理
        photoBrowserAnimator.presentedDelegate = object
        photoBrowserAnimator.indexPath = indexPath
        photoBrowserAnimator.dismissDelegate = photoBrowserVc
        
        present(photoBrowserVc, animated: true, completion: nil)
        
    }
    
}

// MARK:- 请求数据
extension HomeViewController {
    ///加载最新数据
    @objc func loadNewStatuses() {
        loadStatuses(true)
    }
    ///加载更多数据
    @objc func loadMoreStatuses() {
        loadStatuses(false)
    }
    
    private func loadStatuses(_ isNewData: Bool) {
        // 1.获取since_id/max_id
        var since_id = 0
        var max_id = 0
        if isNewData {
            since_id = viewModels.first?.status?.mid ?? 0
        } else {
            max_id = viewModels.last?.status?.mid ?? 0
            max_id = max_id == 0 ? 0 : (max_id - 1)//如果为零取0 否则数据-1 防止重复
        }
        
        NetworkTools.shareInstance.loadStatuses(since_id, max_id) { (result, error) in
            if error != nil {
                print(error!)
                return
            }

            guard let resultArray = result else {
                return
            }
            
            // 3.遍历微博对应的字典
            var tempViewModel = [StatusViewModel]()
            for statusDict in resultArray {
                let status = Status(dict: statusDict)
                let viewModel = StatusViewModel(status: status)
//                self.viewModels.append(viewModel)
                tempViewModel.append(viewModel) //将序列的元素添加到数组的末尾
            }
            
            if isNewData {
                self.viewModels = tempViewModel + self.viewModels
            } else {
                self.viewModels += tempViewModel
            }
//            self.tableView.reloadData()
            self.cacheImages(tempViewModel)
        }
    }
    
    fileprivate func cacheImages(_ viewModels: [StatusViewModel]) {
        //创建组
        let group = DispatchGroup()
        //缓存图片
        for viewModel in viewModels {
            for picURL in viewModel.picURLs {
                group.enter()//进去组
                KingfisherManager.shared.downloader.downloadImage(with: picURL, retrieveImageTask: nil, options: nil, progressBlock: nil) { (_, _ , _, _) in
                    group.leave()
                    //print("下载了一张图片")
                }
            }
        }
        //等所有异步操作完 再进入主队列刷新表格
        group.notify(queue: DispatchQueue.main) { 
            self.tableView.reloadData()
            //print("刷新表格")
            // 停止刷新
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            // 显示提示的Label
            self.showTipLabel(viewModels.count)
        }
    }
    
    
    /// 显示提示的Label
    private func showTipLabel(_ count : Int) {
        tipLabel.isHidden = false
        tipLabel.text = count == 0 ? "没有最新数据" : "更新了\(count) 条微博"
        
        // 2.执行动画
        UIView.animate(withDuration: 1.0, animations: { 
            self.tipLabel.frame.origin.y = 44
        }) { (_) in
            UIView.animate(withDuration: 1.0, delay: 1.5, options: [], animations: { //options 开始 回去 慢 快等等枚举设置
                self.tipLabel.frame.origin.y = 20
            }, completion: { (_) in
                self.tipLabel.isHidden = true
            })
        }
        
    }
    
}

// MARK:- tableView的数据源方法
extension HomeViewController { //swift 本身UITableView是不需要遵守协议 UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeCellID) as! HomeTableViewCell
        
        cell.viewModel = viewModels[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModel = viewModels[indexPath.row]
        return viewModel.cellHeight
    }
}
