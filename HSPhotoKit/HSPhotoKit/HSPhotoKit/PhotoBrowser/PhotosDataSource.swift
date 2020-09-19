//
//  PhotoDataSource.swift
//  HSPhotoKit
//
//  Created by Hanson on 2018/5/8.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import Foundation

public struct PhotosDataSource {
    private(set) var photos: [PhotoViewable] = []
    
    public var numberOfPhotos: Int {
        return photos.count
    }
    
    public func photoAtIndex(_ index: Int) -> PhotoViewable? {
        if (index < photos.count && index >= 0) {
            return photos[index];
        }
        return nil
    }
    
    public func indexOfPhoto(_ photo: PhotoViewable) -> Int? {
        return photos.firstIndex(where: { $0 === photo})
    }

    public func containsPhoto(_ photo: PhotoViewable) -> Bool {
        return indexOfPhoto(photo) != nil
    }
    
    public subscript(index: Int) -> PhotoViewable? {
        get {
            return photoAtIndex(index)
        }
    }
}
