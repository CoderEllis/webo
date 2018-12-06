//
//  AppDelegate.swift
//  wobo
//
//  Created by Soul Ai on 4/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 设置全局颜色
//        UITabBar.appearance().tintColor = UIColor.orange
        
        //创建 Window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarItemContent()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // 当应用程序即将从活动状态转换为非活动状态时发送。对于某些类型的临时中断（例如来电或SMS消息），或者当用户退出应用程序并且它开始转换到后台状态时，可能会发生这种情况。
        // 使用此方法可暂停正在进行的任务，禁用计时器以及使图形渲染回调无效。游戏应该使用此方法暂停游戏
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //使用此方法释放共享资源，保存用户数据，使计时器无效，并存储足够的应用程序状态信息，以便将应用程序恢复到当前状态，以防以后终止。
        // 如果您的应用程序支持后台执行，则该方法被调用而不是Apple将终止：当用户退出时。
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 作为从后台到活动状态的转换的一部分调用；在这里可以撤消在进入后台时所做的许多更改。
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 重新启动在应用程序处于非活动状态时暂停（或尚未启动）的任何任务。如果应用程序先前位于后台，则可选地刷新用户界面。
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 当应用程序即将终止时调用。保存数据，如果合适的话。参见ApdioDestEntudio背景：
    }


}

