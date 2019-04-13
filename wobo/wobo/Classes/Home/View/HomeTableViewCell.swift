//
//  HomeViewCell.swift
//  wobo
//
//  Created by Soul Ai on 20/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate let edgeMargin : CGFloat = 15
fileprivate let itemMargin :CGFloat = 10

class HomeTableViewCell: UITableViewCell {
    
    // MARK:- 控件属性
    @IBOutlet weak var iconView: UIImageView!          //头像
    @IBOutlet weak var verifiedView: UIImageView!      //认证
    @IBOutlet weak var screeNameLabel: UILabel!        //昵称
    @IBOutlet weak var vipView: UIImageView!           //Vip 图标
    @IBOutlet weak var timeLabel: UILabel!             //时间
    @IBOutlet weak var sourceLabel: UILabel!           //来源
    @IBOutlet weak var contentLabel: ELLabel!          //正文
    
    @IBOutlet weak var picView: PicCollectionView!     //配图
    
    @IBOutlet weak var retweetedContentLabel: UILabel!  //转发
    @IBOutlet weak var retweetedBgView: UIView!   //转发的背景
    @IBOutlet weak var bottomToolView: UIView!    //工具栏高度
    
    
    // MARK:- 约束的属性
    @IBOutlet weak var contenLabelCons: NSLayoutConstraint!
    @IBOutlet weak var picViewHCons: NSLayoutConstraint!
    @IBOutlet weak var picViewWCons: NSLayoutConstraint!
    @IBOutlet weak var picViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var retweetedContentLabelTopCons: NSLayoutConstraint!
    
    @IBAction func btnClick(_ sender: Any) {
        print(123)
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.blue
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        
    }
    
    // MARK:- 约束的属性
    var viewModel : StatusViewModel? {
        didSet {
            // 1.nil值校验
            guard let viewModel = viewModel else {
                return
            }
            
             // 2.设置头像
            iconView.kf.setImage(with: viewModel.profileURL, placeholder: UIImage(named: "avatar_default_small"), options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil) //options:渐变的方式显示
            
            // 3.设置认证的图标
            verifiedView.image = viewModel.verifiedImage
            
            // 4.昵称
            screeNameLabel.text = viewModel.status?.user?.screen_name
            
            // 5.会员图标
            vipView.image = viewModel.vipImage
            
            // 6.设置时间的Label
            timeLabel.text = viewModel.createAtText
            
            // 7.设置来源
            if let sourceText = viewModel.sourceText {
                sourceLabel.text = "来自" + sourceText
            } else {
                sourceLabel.text = nil
            }
            
             //微博正文
            contentLabel.attributedText = FindEmoticon.shareIntance.findAttrString(statusText: viewModel.status?.text, font: contentLabel.font)
            
            contentLabel.linkTapHandler = { (_,user,_) in
                print(user)
            }
            contentLabel.userTapHandler = { (_,user,_) in
                print(user)
            }
            
            // 9.设置昵称的文字颜色
            screeNameLabel.textColor = viewModel.vipImage == nil ? UIColor.black : UIColor.orange
            
            //10.计算picView的宽度和高度的约束
            let picViewSize = calculatePicViewSize(viewModel.picURLs.count)
            picViewHCons.constant = picViewSize.height
            picViewWCons.constant = picViewSize.width
            
            //11.将picURL数据传递给picView
            picView.picURLs = viewModel.picURLs
            
            // 12.设置转发微博的正文
            if viewModel.status?.retweeted_status != nil {
                if let screenName = viewModel.status?.retweeted_status?.user?.screen_name, let retweetedText = viewModel.status?.retweeted_status?.text {
                    let retweetedText = "@" + "\(screenName): " + retweetedText
                    
                    retweetedContentLabel.attributedText = FindEmoticon.shareIntance.findAttrString(statusText: retweetedText, font: retweetedContentLabel.font)
                    
                    retweetedContentLabelTopCons.constant = 15
                } 
                retweetedBgView.isHidden = false
                
            } else {
                retweetedContentLabel.text = nil
                retweetedBgView.isHidden = true
                // 3.设置转发正文距离顶部的约束
                retweetedContentLabelTopCons.constant = 0
            }
            
            if viewModel.cellHeight == 0 {
                //强制布局
                layoutIfNeeded()
                //获取底部工具栏的最大Y值
                viewModel.cellHeight = bottomToolView.frame.maxY
            }
        }
    }
    
    
    
    
    
    // MARK:- 系统回调函数
    override func awakeFromNib() {
        super.awakeFromNib()
        // 设置微博正文的宽度约束UICollectionView
        contenLabelCons.constant = ScreenWidth - 2 * edgeMargin
        //注册Cell
        picView.register(PicViewCell.self, forCellWithReuseIdentifier: "PicCell")
        
        
        // 取出picView对应的layout  布局
//        let layout = picView.collectionViewLayout as! UICollectionViewFlowLayout //转成流水布局
//        let imageViewWH = (UIScreen.main.bounds.width - 2 * edgeMargin - 2 * itemMargin) / 3
//        layout.itemSize = CGSize(width: imageViewWH, height: imageViewWH)
        
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}

//MARK:- 计算图片高度
extension HomeTableViewCell {
    private func calculatePicViewSize(_ count: Int) -> CGSize {
        
        if count == 0 {
            picViewBottomCons.constant = 0
            return CGSize.zero
        }
        
        // 有配图需要改约束有值
        picViewBottomCons.constant = 10
        
        // 2.取出picView对应的layout
        let layout = picView.collectionViewLayout as! UICollectionViewFlowLayout //转成流水布局
        
        //3.单张配图cachePath(forKey: urlString!)
        if count == 1 {
            // 1.取出缓存图片
            let urlString = viewModel?.picURLs.last?.absoluteString
            let image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: urlString!)
            
            guard image != nil else {
                print("没有获得一张配图的缓存~~~~~~~")
                layout.itemSize = CGSize(width: 0, height: 0)
                return CGSize.init(width: 0, height: 0)
            }
            layout.itemSize = CGSize(width: (image?.size.width)! * 2, height: (image?.size.height)! * 2)
            return CGSize(width: (image?.size.width)! * 2, height: (image?.size.height)! * 2) //可能下载时将图片压缩了一倍  所以 * 2
        }
        
//            if count == 4 {//四张图片占全屏
//                let fourWH = (UIScreen.main.bounds.width - 2 * edgeMargin - itemMargin) / 2
//                let picViewWH = fourWH * 2 + itemMargin
//                layout.itemSize = CGSize(width: picViewWH, height: picViewWH)
//                return CGSize(width: picViewWH, height: picViewWH)
//            }
        
        // 4.计算出来imageViewWH
        let imageViewWH = (ScreenWidth - 2 * edgeMargin - 2 * itemMargin) / 3
        
        // 5.设置其他张图片时layout的itemSize
        layout.itemSize = CGSize(width: imageViewWH, height: imageViewWH)
        
        //.四张配图
        if count == 4{
            let picViewWH = imageViewWH * 2 + itemMargin + 1
            return CGSize(width: picViewWH, height: picViewWH)
        }
        
        // 7.其他张配图
        //计算行数
        let rows = CGFloat((count - 1) / 3 + 1)
        
        // 7.2.计算picView的高度
        let picViewH = rows * imageViewWH + (rows - 1) * itemMargin
        let picViewW = ScreenWidth - 2 * edgeMargin
        return CGSize(width: picViewW, height: picViewH)
        
    }
}



