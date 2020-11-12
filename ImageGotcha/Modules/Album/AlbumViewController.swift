//
//  AlbumViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/4/22.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import SnapKit
import HSPhotoKit
import Blueprints

class AlbumViewController: UIViewController {

    fileprivate let cellId = "AlbumCollectionViewCell"
    var saveImageShareDirectory: URL?
    var photos: [Photo] = []
    var photoToDelete: [Photo] = []
    var cellModels: [CellModel] = [] {
        didSet {
            noPhotoLabel.isHidden = (cellModels.count > 0) ? true : false
        }
    }
    
    lazy var selectImageButton: UIBarButtonItem = {
        let awareBarButtonItem = UIBarButtonItem(title: LocalizedStr.select, style: UIBarButtonItem.Style.plain, target: self, action: #selector(toggleSelectState))
        return awareBarButtonItem
    }()
    
    lazy var collectionView: SwipeSelectingCollectionView = {
        var flowlayout = UICollectionViewFlowLayout()
        if UIDevice.current.userInterfaceIdiom == .pad {
            flowlayout = iPadOSLayout
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            flowlayout = iOSLayout
        }
        #if targetEnvironment(macCatalyst)
        flowlayout = iPadOSLayout
        #endif
        let collectionView = SwipeSelectingCollectionView(frame: .zero, collectionViewLayout: flowlayout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor.systemGroupedBackground
        } else {
            collectionView.backgroundColor = UIColor.white
        }
        collectionView.register(UINib(nibName: "AlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    lazy var noPhotoLabel: UILabel = {
        let label = UILabel()
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = UIColor.white
        }
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = LocalizedStr.noPhoto
        label.textAlignment = .center
        return label
    }()
    
    let iOSLayout = VerticalBlueprintLayout(
        itemsPerRow: 3,
        height: 90,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 15,
        sectionInset: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
        stickyHeaders: false,
        stickyFooters: false)
    
    let iPadOSLayout = VerticalBlueprintLayout(
        itemsPerRow: 6,
        height: 90,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 15,
        sectionInset: EdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
        stickyHeaders: false,
        stickyFooters: false)
    
    lazy var toolBarView = AlbumViewBottomToolBar()
    var isSelectState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        getShareDirectory()
        getImageData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem = selectImageButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Private Function
extension AlbumViewController {
    
    private func setUpView() {
        self.title = LocalizedStr.album
        
        toolBarView.isHidden = true
        toolBarView.selectAllButton.addTarget(self, action: #selector(selectAllImage), for: .touchUpInside)
        toolBarView.deleteButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
        self.view.addSubview(collectionView)
        self.view.addSubview(toolBarView)
        collectionView.backgroundView = noPhotoLabel
        
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(view.snp.bottomMargin)
        }
    }
    
    private func getShareDirectory() {
        let shareDictory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupId)
        let imageFolder = shareDictory!.appendingPathComponent("Images", isDirectory: true)
        let exist = FileManager.default.fileExists(atPath: imageFolder.path)
        if !exist {
            do {
                try FileManager.default.createDirectory(at: imageFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error to create share directory")
            }
        }
        saveImageShareDirectory = imageFolder
    }
    
    private func getImageData() {
        guard let saveImageShareDirectory = saveImageShareDirectory else { return }
        do {
            photos.removeAll()
            cellModels.removeAll()
            let imageNames = try FileManager.default.contentsOfDirectory(atPath: saveImageShareDirectory.path)
            for imageName in imageNames {
                let imageURL = saveImageShareDirectory.appendingPathComponent(imageName)
                let imageDataPath = imageURL.path
                if let imageData = FileManager.default.contents(atPath: imageDataPath) {
                    let image = UIImage(data: imageData)
                    let photo = Photo(image: image)
                    photos.append(photo)
                    var cellModel = CellModel()
                    cellModel.photo = photo
                    cellModel.photo.imageURL = imageURL
                    cellModels.append(cellModel)
                }
            }
            self.collectionView.reloadData()
            
        } catch {
            
        }
    }
    
    @objc private func toggleSelectState() {
        isSelectState = !isSelectState
        collectionView.isSwipeSelectingEnable = isSelectState
        selectImageButton.title = isSelectState ? LocalizedStr.cancel : LocalizedStr.select
        
        toolBarView.isHidden = false
        let bottomConstant: CGFloat = isSelectState ? -44 : 44
        UIView.animate(withDuration: 0.3) {
            self.toolBarView.transform = CGAffineTransform(translationX: 0, y: bottomConstant)
        }
        
        if !isSelectState {
            for i in 0 ..< cellModels.count {
                cellModels[i].isSelected = false
                toolBarView.selectAllButton.isSelected = false
            }
            collectionView.reloadData()
        }
    }
    
    @objc private func selectAllImage(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        for i in 0 ..< cellModels.count {
            cellModels[i].isSelected = sender.isSelected
        }
        for index in 0..<cellModels.count {
            let indexPath = IndexPath(item: index, section: 0)
            if sender.isSelected {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            } else {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
    }
    
    @objc private func deleteImage(sender: UIButton) {
        photoToDelete.removeAll()
        for model in cellModels {
            if model.isSelected {
                photoToDelete.append(model.photo)
            }
        }
        for item in photoToDelete {
            guard let url = item.imageURL else { continue }
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                print(" Error: \(error.localizedDescription)")
            }
        }
        getImageData()
        toggleSelectState()
    }
    
    private func showShareImage(photo: PhotoViewable) {
        guard let image = photo.image else { return }
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIApplication.presentedViewController(rootController: self)?.present(activityViewController, animated: true, completion: nil)
        } else {
            let popoverController = activityViewController.popoverPresentationController
            popoverController?.sourceView = self.view
            // TODO: - Test in iPad
//            popoverController?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height, width: 0, height: 0)
            UIApplication.presentedViewController(rootController: self)?.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? AlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(cellModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isSelectState else { return }
        cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentPhoto = photos[indexPath.row]
        let currentItem = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
        
        if isSelectState {
            cellModels[indexPath.row].isSelected = !cellModels[indexPath.row].isSelected
            // CollectionView 会调用 Cell 的 isSelected 属性；故无须设置 currentItem.configureCell(cellModels[indexPath.row])
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            let galleryPreview = PhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: currentItem, actionButtonStyle: .share, isHideURLTextView: true)
            galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
                if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                    let currentSelectedIndexPath = IndexPath(item: index, section: indexPath.section)
                    if let cell = collectionView.cellForItem(at: currentSelectedIndexPath) as? AlbumCollectionViewCell {
                        return cell.imageView
                    }
                    return nil
                }
                return nil
            }
            galleryPreview.actionButtonTappedHandler = { [weak self] (photo) in
                self?.showShareImage(photo: photo)
            }
            self.present(galleryPreview, animated: true, completion: nil)
        }
    }
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemNum: CGFloat = 3
        var windowWidth = ScreenWidth
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                itemNum = 6
            } else {
                itemNum = 4
            }
        }
        #if targetEnvironment(macCatalyst)
        itemNum = 6
        if let windowBounds = UIApplication.shared.activeWindowScene?.coordinateSpace.bounds {
            windowWidth = windowBounds.width
        }
        #endif
        let itemSpace = 5 * (itemNum - 1)
        let itemWidth = (windowWidth - itemSpace) / itemNum
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
