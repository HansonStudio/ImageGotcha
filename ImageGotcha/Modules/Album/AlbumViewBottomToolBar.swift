//
//  AlbumViewBottomToolBar.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/9.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class AlbumViewBottomToolBar: UIView {

    lazy var selectAllButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(rgba: "#2F8BF8"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle(LocalizedStr.cancelSelectAll, for: .selected)
        button.setTitle(LocalizedStr.selectAll, for: .normal)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle(LocalizedStr.delete, for: .normal)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(rgba: "#E5E5E5").withAlphaComponent(0.9)
        self.addSubview(selectAllButton)
        self.addSubview(deleteButton)
        selectAllButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        deleteButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
