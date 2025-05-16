//
//  EnvironmentUtility.swift
//  GitHub
//
//  Created by Dishcool on 2025/5/17.
//

import Foundation

/// Utility for determining runtime environment conditions
struct EnvironmentUtility {
    
    /// Determines if the code is running in a simulator environment
    /// - Returns: True if running in a simulator, false if running on a physical device
    static var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
    
    /// Determines if the app is running in debug mode
    /// - Returns: True if in debug mode, false if in release mode
    static var isDebugMode: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    /// Determines if the app is running UI tests
    /// - Returns: True if running UI tests
    static var isRunningUITests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    /// The current version of the app as defined in the Info.plist
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// The current build number of the app as defined in the Info.plist
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
} 