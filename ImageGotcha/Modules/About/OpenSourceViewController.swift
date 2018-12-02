//
//  OpenSourceViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/11.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import SafariServices

class OpenSourceViewController: UIViewController {
    
    lazy var tableView = UITableView()

    let opensources = ["Kingfisher", "SnapKit"]
    let opensourcesUrl = ["https://github.com/onevcat/Kingfisher/blob/master/LICENSE", "https://github.com/SnapKit/SnapKit/blob/develop/LICENSE"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.whiteBackground
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OpenSourceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return opensources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = opensources[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let url = URL(string: opensourcesUrl[indexPath.row]) {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true)
        }
    }
}

