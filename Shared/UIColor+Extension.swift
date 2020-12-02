//
//  Extension.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/4/22.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(rgba: String) {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            var hexStr = (rgba as NSString).substring(from: 1) as NSString
            if hexStr.length == 8 {
                let alphaHexStr = hexStr.substring(from: 6)
                hexStr = hexStr.substring(to: 6) as NSString
                
                var alphaHexValue: UInt64 = 0
                let alphaScanner = Scanner(string: alphaHexStr)
                if alphaScanner.scanHexInt64(&alphaHexValue) {
                    let alphaHex = Int(alphaHexValue)
                    alpha = CGFloat(alphaHex & 0x000000FF) / 255.0
                } else {
                    dPrint("scan alphaHex error")
                }
            }
            
            let rgbScanner = Scanner(string: hexStr as String)
            
            var hexValue: UInt64 = 0
            if rgbScanner.scanHexInt64(&hexValue) {
                if hexStr.length == 6 {
                    let hex = Int(hexValue)
                    red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hex & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hex & 0x0000FF) / 255.0
                } else {
                    dPrint("invalid rgb string, length should be 6")
                }
            } else {
                dPrint("scan hex error")
            }
        } else {
            dPrint("invalid rgb string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
