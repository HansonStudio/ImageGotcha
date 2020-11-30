//
//  Common.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2020/11/30.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import Foundation

/// Debug 时候打印信息
///
/// - Parameter item: 要打印的内容
func dPrint(_ item: @autoclosure () -> Any) {
    #if DEBUG
    print(item())
    #endif
}
