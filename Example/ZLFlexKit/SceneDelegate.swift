//
//  SceneDelegate.swift
//  ZLFlexKit_Example
//
//  UIScene 生命周期适配
//
//  说明：
//  · iOS 13 起，UIKit 把「App 生命周期」与「UI 生命周期」拆开：
//      - AppDelegate  负责进程级事件（启动、注册推送、scene 配置分发…）
//      - SceneDelegate 负责界面级事件（window 创建、前后台切换…）
//  · window 必须由 UIWindowScene 创建：UIWindow(windowScene:)
//    不能再用 UIWindow(frame: UIScreen.main.bounds)，否则多窗口/分屏会错乱。
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// 注意：window 现在归 SceneDelegate 持有，AppDelegate 不再持有 window
    var window: UIWindow?

    // MARK: - 连接 / 断开

    /// scene 即将接入，在这里搭建窗口与根控制器
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        // 必须转成 UIWindowScene，非 UI 场景（如 CarPlay）直接返回
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = SceneDelegate.makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window

        // 冷启动时如果是被 URL / 快捷方式 / 通知唤起，参数都在 connectionOptions 里
        if let urlContext = connectionOptions.urlContexts.first {
            handle(url: urlContext.url)
        }
        if let shortcut = connectionOptions.shortcutItem {
            handle(shortcutItem: shortcut)
        }
    }

    /// scene 被系统回收（从多任务卡片上划掉，或系统内存回收）
    func sceneDidDisconnect(_ scene: UIScene) {
        // 释放该 scene 独占的资源；下次重新连接会再走 willConnectTo
    }

    // MARK: - 前后台 / 活跃状态

    /// 变为活跃（可接收用户事件）
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 恢复被暂停的任务，刷新 UI
    }

    /// 即将变为非活跃（来电、下拉通知中心、多任务切换中）
    func sceneWillResignActive(_ scene: UIScene) {
        // 暂停计时器、游戏、视频等
    }

    /// 即将进入前台
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 撤销进入后台时做的降级处理
    }

    /// 已经进入后台
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 保存数据、释放共享资源
    }

    // MARK: - 热启动入口（App 已在运行时被唤起）

    /// 通过 URL Scheme / Universal Link 打开
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { handle(url: $0.url) }
    }

    /// 通过 3D Touch / 长按图标的快捷方式打开
    func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        handle(shortcutItem: shortcutItem)
        completionHandler(true)
    }

    // MARK: - 私有

    /// 构建根控制器：优先用 Main.storyboard 的 initial VC，失败再兜底纯代码创建
    private static func makeRootViewController() -> UIViewController {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            return vc
        }
        // 兜底：Demo 列表 + 导航栏
//        let nav = UINavigationController(rootViewController: FlexKitDemoViewController())
        let nav = UINavigationController(rootViewController: ViewController())

        return nav
    }

    private func handle(url: URL) {
        print("[SceneDelegate] openURL: \(url)")
    }

    private func handle(shortcutItem: UIApplicationShortcutItem) {
        print("[SceneDelegate] shortcut: \(shortcutItem.type)")
    }
}
