//
//  ImageGalleryViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2020/12/2.
//  Copyright © 2020 HansonStudio. All rights reserved.
//

import UIKit
import HSPhotoKit
import Blueprints

class ImageGalleryViewController: UIViewController {

    var collectionView: UICollectionView!
    var toolBarView: BottomToolBar!
    var galleryPreviewer: PhotosViewController?
    
    var photos: [Photo] = []
    var cellModels: [ImageGalleryCellModel] = [] {
        didSet {
            noPhotoLabel.isHidden = (cellModels.count > 0) ? true : false
        }
    }
    
    lazy var noPhotoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = LocalizedStr.noPhoto
        label.textAlignment = .center
        return label
    }()
    
    lazy var shareButton: UIButton = {
        let shareButton = UIButton()
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: largeConfig)
        shareButton.setBackgroundImage(image, for: .normal)
        shareButton.addTarget(self, action: #selector(showShareImage), for: .touchUpInside)
        return shareButton
    }()
    
    let iOSLayout = VerticalBlueprintLayout(
        itemsPerRow: 3,
        height: 90,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: EdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        stickyHeaders: false,
        stickyFooters: false)
    
    let iPadOSLayout = VerticalBlueprintLayout(
        itemsPerRow: 6,
        height: 90,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: EdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
        stickyHeaders: false,
        stickyFooters: false)
    
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium, scale: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        guard isEditing != editing else { return }
        super.setEditing(editing, animated: animated)
        // 注意开启关闭多选(目前测试发现 iOS14 上 CollectionView 单个手指也能触发多选)
        collectionView.allowsMultipleSelection = editing
        if #available(iOS 14.0, *) {
            collectionView.allowsMultipleSelectionDuringEditing = editing
        }
        if !editing {
            clearSelectedItems(animated: true)
        }
        updateRightBarButtonTitle()
        updateBottomToolBar()
    }
    
    @objc func bottomToolBarRightButtonDidTap(sender: UIButton) {
        
    }

    @objc func toggleSelectionMode() {
        setEditing(!isEditing, animated: true)
    }
    
    private func clearSelectedItems(animated: Bool) {
        collectionView.indexPathsForSelectedItems?.forEach({ (indexPath) in
            collectionView.deselectItem(at: indexPath, animated: animated)
        })
    }
    
    @objc private func selectAllImage(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for i in 0 ..< cellModels.count {
            cellModels[i].isSelected = sender.isSelected
        }
        for index in 0..<cellModels.count {
            let indexPath = IndexPath(item: index, section: 0)
            if sender.isSelected {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
    }
}


// MARK: - UI
extension ImageGalleryViewController {
    private func setupView() {
        let selectImageButton = UIBarButtonItem(title: LocalizedStr.select, style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleSelectionMode))
        navigationItem.rightBarButtonItem = selectImageButton
        
        setupCollectionView()
        setupBottomToolView()
        setEditing(false, animated: false)
    }
    
    private func setupCollectionView() {
        var flowlayout = UICollectionViewFlowLayout()
        if UIDevice.current.userInterfaceIdiom == .pad {
            flowlayout = iPadOSLayout
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            flowlayout = iOSLayout
        } else {
            flowlayout = iPadOSLayout
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
        collectionView.register(cellType: ImageCollectionViewCell.self)
        collectionView.backgroundView = noPhotoLabel
        collectionView.allowsMultipleSelection = false
        if #available(iOS 14.0, *) {
            // ⚠️ iOS 14 需配置这个属性后，其实不需要再调用 shouldBeginMultipleSelectionInteractionAt delegate 方法
            collectionView.allowsSelectionDuringEditing = true
            collectionView.allowsMultipleSelectionDuringEditing = true
        }
        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupBottomToolView() {
        toolBarView = BottomToolBar()
        toolBarView.isHidden = true
        toolBarView.selectAllButton.addTarget(self, action: #selector(selectAllImage), for: .touchUpInside)
        toolBarView.rightButton.addTarget(self, action: #selector(bottomToolBarRightButtonDidTap), for: .touchUpInside)
        view.addSubview(toolBarView)
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(view.snp.bottomMargin)
        }
    }
    
    private func updateRightBarButtonTitle() {
        guard let button = navigationItem.rightBarButtonItem else { return }
        button.title = isEditing ? LocalizedStr.cancel : LocalizedStr.select
    }
    
    private func updateBottomToolBar() {
        toolBarView.isHidden = false
        let bottomConstant: CGFloat = isEditing ? -44 : 44
        UIView.animate(withDuration: 0.3) {
            self.toolBarView.transform = CGAffineTransform(translationX: 0, y: bottomConstant)
        }
    }
}
