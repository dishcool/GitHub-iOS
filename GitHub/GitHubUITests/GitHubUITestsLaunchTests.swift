//
//  GitHubUITestsLaunchTests.swift
//  GitHubUITests
//
//  Created by Jacky Lam on 2025/5/15.
//

import XCTest

final class GitHubUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 等待应用完全加载
        sleep(2)
        
        // 验证关键UI元素是否存在
        XCTAssertTrue(app.tabBars.firstMatch.exists, "标签栏应该存在")
        
        // 验证应用是否正确启动到登录页面或主页
        let loginTitle = app.staticTexts["GitHub iOS客户端"]
        let tabBar = app.tabBars.firstMatch
        
        XCTAssertTrue(loginTitle.exists || tabBar.exists, "应用应该显示登录页面或主界面")
        
        // 检查应用是否响应交互
        if tabBar.exists {
            // 找到主页标签（可能是第一个按钮，也可能需要通过名称查找）
            let homeTabNames = ["主页", "Home", "首页", "发现"]
            var homeTab: XCUIElement? = nil
            
            // 尝试通过名称查找主页标签
            for name in homeTabNames {
                let tab = tabBar.buttons[name]
                if tab.exists {
                    homeTab = tab
                    break
                }
            }
            
            // 如果没找到，使用第一个标签页
            if homeTab == nil {
                homeTab = tabBar.buttons.element(boundBy: 0)
            }
            
            homeTab?.tap()
            
            // 等待页面加载
            sleep(2)
            
            // 检查多种可能的内容容器
            let contentExists = app.collectionViews.firstMatch.exists || 
                               app.tables.firstMatch.exists ||
                               app.scrollViews.firstMatch.exists ||
                               app.staticTexts.count > 1
            
            XCTAssertTrue(contentExists, "主页内容应该加载")
            
            // 如果上面的检查失败，打印UI调试信息
            if !contentExists {
                print("当前UI层次结构:")
                print(app.debugDescription)
            }
        }

        // 截取启动屏幕截图
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // 添加设备信息
        let deviceInfo = """
        Device: \(UIDevice.current.name)
        iOS Version: \(UIDevice.current.systemVersion)
        Model: \(UIDevice.current.model)
        """
        
        let deviceInfoAttachment = XCTAttachment(string: deviceInfo)
        deviceInfoAttachment.name = "Device Info"
        deviceInfoAttachment.lifetime = .keepAlways
        add(deviceInfoAttachment)
    }
    
    @MainActor
    func testAppIcon() throws {
        // 验证应用图标是否存在于主屏幕
        // 注意：这个测试可能需要特殊权限，可能在某些环境中不工作
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        // 尝试在主屏幕上找到应用图标
        let appIcon = springboard.icons["GitHub"]
        
        if appIcon.exists {
            // 截图应用图标
            let attachment = XCTAttachment(screenshot: appIcon.screenshot())
            attachment.name = "App Icon"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        
        // 启动应用
        let app = XCUIApplication()
        app.launch()
        
        // 验证应用是否成功启动
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "应用应该在前台运行")
    }
}
