//
//  SceneDelegate.swift
//  ImageGotcha
//
//  Created by Hanson on 2020/11/9.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
        
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let vc = HomeViewController()
            window.rootViewController = UINavigationController(rootViewController: vc)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        setWindowSizeRestrictionForMac()
        #endif
    }
    
    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
            // dPrint("\(windowScene.coordinateSpace.bounds)")
    }
    
    private func setWindowSizeRestrictionForMac() {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 800)
        }
    }
}

