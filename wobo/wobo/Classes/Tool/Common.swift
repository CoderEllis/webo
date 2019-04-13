//
//  Common.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

// MARK: - UI常量
///屏幕宽度
let ScreenWidth = UIScreen.main.bounds.size.width
///屏幕高度
let ScreenHeight = UIScreen.main.bounds.size.height
let ScreenScale = UIScreen.main.scale

///状态栏高度
let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
///导航栏高度
let navigationHeight = (statusBarHeight + 44)
///tabbar高度
let tabBarHeight = CGFloat(statusBarHeight == 44 ? 83 : 49)

///顶部的安全距离
let topSafeAreaHeight = (statusBarHeight - 20)
///底部的安全距离
let bottomSafeAreaHeight = CGFloat(tabBarHeight - 49)


// MARK:- 授权的常量
let app_key = "2230450316"
let app_secret = "5c901ea61007954c6719e24b3fd89fcb"
let redirect_uri = "https://github.com/CoderEllis"

// MARK:- 选择照片的通知常量
let PicPickerAddPhotoNote = "PicPickerAddPhotoNote"
let PicPickerRemovePhotoNote = "PicPickerRemovePhotoNote"

// MARK:- 照片浏览器的通知常量
let ShowPhotoBrowserNote = "ShowPhotoBrowserNote"
let ShowPhotoBrowserIndexKey = "ShowPhotoBrowserIndexKey"
let ShowPhotoBrowserUrlsKey = "ShowPhotoBrowserUrlsKey"
