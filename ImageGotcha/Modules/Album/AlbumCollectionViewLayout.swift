//
//  AlbumCollectionViewLayout.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/5.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class AlbumCollectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        self.basciInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.basciInit()
    }
    
    override func prepare() {
        //设置边距
        self.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

extension AlbumCollectionViewLayout {
    private func basciInit() {
        var itemNum: CGFloat = 3
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            itemNum = 6
        }
        let itemSpace = 5 * (itemNum - 1)
        let itemWidth = (ScreenWidth - itemSpace) / itemNum
        self.itemSize = CGSize(width: itemWidth, height: itemWidth)
        self.scrollDirection = .vertical
        self.minimumLineSpacing = 5
        self.minimumInteritemSpacing = 5
    }
}
