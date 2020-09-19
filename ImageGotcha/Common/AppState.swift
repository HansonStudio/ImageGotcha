//
//  AppState.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/2.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import Foundation

enum AppInstallState {
    case update
    case newInstall
    case noUpdates
}

class AppState {

    class func version() -> String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as AnyObject).description ?? ""
    }
    
    class func appInstallState() -> AppInstallState {
        let userDefaults = UserDefaults.standard
        if let versionValue = userDefaults.string(forKey: "currentVersion") {
            if versionValue != (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as AnyObject).description {
                updateVersion()
                return .update
            }
            return .noUpdates
        } else {
            updateVersion()
            return .newInstall
        }
    }
    
    private class func updateVersion() {
        if let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as AnyObject).description {
            let userDefaults = UserDefaults.standard
            userDefaults.set(version, forKey: "currentVersion")
        }
    }
}
