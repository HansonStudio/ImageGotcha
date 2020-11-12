//
//  Common.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/4/17.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

extension UIScreen {
    public static var universalBounds: CGRect {
        #if targetEnvironment(macCatalyst)
        if let bounds = UIApplication.shared.activeWindowScene?.coordinateSpace.bounds {
            return bounds
        }
        return UIScreen.main.bounds
        #else
        return UIScreen.main.bounds
        #endif
    }
}

/// Debug 时候打印信息
///
/// - Parameter item: 要打印的内容
public func dPrint(_ item: @autoclosure () -> Any) {
    #if DEBUG
    print(item())
    #endif
}

extension UIApplication {
    
    /// 获取当前正在展示的`ViewController`
    ///
    /// - Parameter rootController: 指定root controller
    /// - Returns: 正在展示的`ViewController`
    public static func presentedViewController(rootController: UIViewController?) -> UIViewController? {
        
        if let navigationController = rootController as? UINavigationController {
            return presentedViewController(rootController: navigationController.visibleViewController)
        }
        
        if let tabBarController = rootController as? UITabBarController {
            if let selectedController = tabBarController.selectedViewController {
                return presentedViewController(rootController: selectedController)
            }
        }
        
        if let presented = rootController?.presentedViewController {
            return presentedViewController(rootController: presented)
        }
        
        return rootController
    }
}
