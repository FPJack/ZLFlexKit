//
//  AppDelegate.swift
//  ZLFlexKit
//
//  Created by fanpeng on 06/08/2026.
//  Copyright (c) 2026 fanpeng. All rights reserved.
//

import UIKit

protocol TestViewA where Self: UIView {
    
}

extension UIView: TestViewA {
    
}

protocol TestViewB where Self: UIView {
    
}

extension UIView: TestViewB {
}


class TestObj<T: TestViewB> {
    var view: T
    init(view: T) {
        self.view = view
    }
}
func testView<T>(_ view: T) -> TestObj<T>? where T: TestViewA {
    return TestObj(view: UILabel() as! T)
}


func testView2<T>() -> TestObj<T>? {
    let v1 = TestObj(view: UIView())
    let v2 = TestObj(view: UILabel())
    
    testView(UIView())
    
    return v2 as? TestObj<T>
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // ⚠️ UIScene 适配后，window 由 SceneDelegate 持有，AppDelegate 不再声明 window
    //    这里保留 var window 会导致系统走「兼容模式」，Scene 回调可能不触发。

    // MARK: - 进程级生命周期

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 这里只做与界面无关的初始化：SDK 注册、日志、数据库…
        // 界面搭建请放到 SceneDelegate.scene(_:willConnectTo:options:)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // App 即将终止（Scene 模式下不一定会调用，重要数据请在 sceneDidEnterBackground 保存）
    }

    // MARK: - UIScene 配置分发

    /// 系统每创建一个 scene session 都会问一次用哪套配置
    /// 这里返回的配置名必须与 Info.plist → UIApplicationSceneManifest 中的 UISceneConfigurationName 一致
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

    /// 用户在多任务界面上划关闭了某些窗口后回调
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 释放这些 session 对应的、不再需要的资源
    }
}

