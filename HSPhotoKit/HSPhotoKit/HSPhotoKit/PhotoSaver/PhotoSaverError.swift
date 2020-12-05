//
//  PhotoSaverError.swift
//  HSPhotoKit
//
//  Created by Hanson on 2020/12/5.
//

import Foundation

public enum PhotoSaverError: Error {
    case limitedAccess
    case denied
    case createAlbumFail(description: String)
    case system(description: String?)
}

extension PhotoSaverError {
    public var localizedDescription: String {
        switch self {
        case .limitedAccess:
            return "权限不足"
        case .createAlbumFail(let description):
            return "创建相册失败: \(description)"
        case .denied:
            return "相册权限被禁"
        case .system(let description):
            return description ?? "unknow"
        }
    }
}
