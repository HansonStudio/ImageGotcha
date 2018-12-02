//
//  TableViewCell.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/4/22.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    lazy var holderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.greyBackground
        view.layer.borderColor = UIColor.seperateColor.cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var titileLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.greyFont
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: -

extension TableViewCell {
    
    private func baseInit() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.whiteBackground
        holderView.addSubview(titileLabel)
        contentView.addSubview(holderView)
        
        titileLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        holderView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        }
    }
}
