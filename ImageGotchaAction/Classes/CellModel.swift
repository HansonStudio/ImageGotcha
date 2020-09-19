//
//  CellModel.swift
//  ImageGotchaAction
//
//  Created by Hanson on 2018/7/30.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import Foundation
import HSPhotoKit

enum CellModelType: Int {
    case image, video
}

struct CellModel {
    var isSelected: Bool = false
    var isSaved: Bool = false
    var photo: Photo?
    var videoUrl: URL?
    var cellModelType: CellModelType = .image
}
