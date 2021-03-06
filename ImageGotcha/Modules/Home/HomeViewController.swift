//
//  HomeViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/3/7.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Reusable

enum homeSection {
    case tutorial, openSafari, album, about
    
    var description: String {
        switch self {
        case .tutorial: return LocalizedStr.tutorial
        case .openSafari: return LocalizedStr.openSafari
        case .album: return LocalizedStr.album
        case .about: return LocalizedStr.about
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .tutorial: return UIImage(systemName: "book")
        case .openSafari: return nil
        case .album: return UIImage(systemName: "photo.on.rectangle")
        case .about: return UIImage(systemName: "info.circle")
        }
    }
}

class HomeViewController: UIViewController {
    
    private let dataSet: [homeSection] = [.tutorial, .album, .about]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(cellType: UITableViewCell.self)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "ImageGotcha"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let dictory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dPrint("documentDirectory: " + "\(dictory)")
        
        let shareDictory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.hanson.imagegotcha")
        dPrint("group dictory: " + "\(String(describing: shareDictory))")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Function

extension HomeViewController {
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSet.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let data = dataSet[indexPath.section]
        cell.imageView?.image = data.icon
        cell.textLabel?.text = data.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = dataSet[indexPath.section]
        switch section {
        case .tutorial:
            self.navigationController?.pushViewController(TutorialViewController(nibName: "TutorialViewController", bundle: nil), animated: true)
        case .openSafari:
            ImageCache.default.clearDiskCache()
            ImageCache.default.cleanExpiredDiskCache()
            // 如果配置了默认浏览器，就不是打开 Safari 了。
            open(scheme: "http://www.bing.com")
        case .album:
            self.navigationController?.pushViewController(AlbumViewController(), animated: true)
        case .about:
            self.navigationController?.pushViewController(AboutViewController(nibName: "AboutViewController", bundle: nil), animated: true)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension UITableViewCell: Reusable { }
