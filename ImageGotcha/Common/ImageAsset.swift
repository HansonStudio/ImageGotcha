//
//  Created by Hanson on 2018.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//


// Generated using SwiftGen, using vy-templete created by Hanson

import UIKit.UIImage

typealias Image = UIImage

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

enum Asset {
  static let app = ImageAsset(name: "App")
  static let actionIcon = ImageAsset(name: "actionIcon")
  static let back = ImageAsset(name: "back")
  static let enable = ImageAsset(name: "enable")
  static let more = ImageAsset(name: "more")
  static let safari = ImageAsset(name: "safari")
  static let screenShot = ImageAsset(name: "screenShot")
  static let screenshotMac = ImageAsset(name: "screenshot_mac")
  static let select = ImageAsset(name: "select")
  static let toShare = ImageAsset(name: "toShare")
}


extension Image {
  convenience init!(asset: ImageAsset) {
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
  }
}


private final class BundleToken {}
