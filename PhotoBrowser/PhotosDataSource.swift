

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
        return photos.index(where: { $0 === photo})
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
