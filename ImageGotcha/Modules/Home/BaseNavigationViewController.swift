//
//  BaseNavigationViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/4/22.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 全局配置导航栏的颜色
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.greyFont
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.greyFont]
        
        interactivePopGestureRecognizer?.delegate = self
    }
    
    // 自定义的返回按钮
    var backButtonItem: [UIBarButtonItem] {
        let backButton = UIButton()//UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backButton.setBackgroundImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,action: nil)
        spacer.width = -11
        let barButtonItem = UIBarButtonItem(customView: backButton)
        return [barButtonItem, spacer]
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if childViewControllers.count > 0 {
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            viewController.navigationItem.leftBarButtonItems = backButtonItem
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)

    }

    @objc func backBtnClick() {
        popViewController(animated: true)
    }
}

extension BaseNavigationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == self.interactivePopGestureRecognizer) {
            return self.viewControllers.count > 1
        }
        return true
    }
}
