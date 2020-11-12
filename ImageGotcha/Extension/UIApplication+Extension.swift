//
//  UIApplication+Extension.swift
//  ImageGotcha
//
//  Created by Hanson on 2020/11/12.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }.first?.windows
            .filter { $0.isKeyWindow }.first
    }
    
    var activeWindowScene: UIWindowScene? {
        self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }.first
    }
}
