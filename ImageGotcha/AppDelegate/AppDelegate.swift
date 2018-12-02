//
//  AppDelegate.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/3/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setUpWindowAndRootView()
        
        return true
    }
}

extension AppDelegate {
    private func setUpWindowAndRootView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        window!.makeKeyAndVisible()
        
        let vc = ViewController()
        window!.rootViewController = BaseNavigationViewController(rootViewController: vc)
    }
}
