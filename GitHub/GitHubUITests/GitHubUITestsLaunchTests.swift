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

        // Wait for the app to fully load
        sleep(2)
        
        // Verify key UI elements exist
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Tab bar should exist")
        
        // Verify app correctly launches to login page or home page
        let loginTitle = app.staticTexts["GitHub iOS Client"]
        let tabBar = app.tabBars.firstMatch
        
        XCTAssertTrue(loginTitle.exists || tabBar.exists, "App should display login page or main interface")
        
        // Check if the app responds to interaction
        if tabBar.exists {
            // Find home tab (could be the first button, or may need to search by name)
            let homeTabNames = ["Home", "Homepage", "Discover", "Main"]
            var homeTab: XCUIElement? = nil
            
            // Try to find home tab by name
            for name in homeTabNames {
                let tab = tabBar.buttons[name]
                if tab.exists {
                    homeTab = tab
                    break
                }
            }
            
            // If not found, use the first tab
            if homeTab == nil {
                homeTab = tabBar.buttons.element(boundBy: 0)
            }
            
            homeTab?.tap()
            
            // Wait for page to load
            sleep(2)
            
            // Check various possible content containers
            let contentExists = app.collectionViews.firstMatch.exists || 
                               app.tables.firstMatch.exists ||
                               app.scrollViews.firstMatch.exists ||
                               app.staticTexts.count > 1
            
            XCTAssertTrue(contentExists, "Homepage content should load")
            
            // If above checks fail, print UI debug information
            if !contentExists {
                print("Current UI hierarchy:")
                print(app.debugDescription)
            }
        }

        // Take launch screen screenshot
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        // Add device information
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
        // Verify app icon exists on home screen
        // Note: This test may require special permissions and might not work in some environments
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        // Try to find app icon on home screen
        let appIcon = springboard.icons["GitHub"]
        
        if appIcon.exists {
            // Screenshot app icon
            let attachment = XCTAttachment(screenshot: appIcon.screenshot())
            attachment.name = "App Icon"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        
        // Launch app
        let app = XCUIApplication()
        app.launch()
        
        // Verify app launches successfully
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App should be running in foreground")
    }
}
