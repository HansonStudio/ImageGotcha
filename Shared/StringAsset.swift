//
//  Created by Hanson on 2018.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//


// Generated using SwiftGen, template by Hanson

import Foundation

enum LocalizedStr {
  /// 关于
  static let about = LocalizedStr.tr("Localizable", "about")
  /// 相册
  static let album = LocalizedStr.tr("Localizable", "album")
  /// 取消
  static let cancel = LocalizedStr.tr("Localizable", "cancel")
  /// 取消全选
  static let cancelSelectAll = LocalizedStr.tr("Localizable", "cancelSelectAll")
  /// 删除
  static let delete = LocalizedStr.tr("Localizable", "delete")
  /// 反馈
  static let feedback = LocalizedStr.tr("Localizable", "feedback")
  /// ImageGotcha
  static let imageGotcha = LocalizedStr.tr("Localizable", "ImageGotcha")
  /// ImageGotcha 是一个 Safari 的 Extension，它可以提取当前网页的图片，方便你查看和保存
  static let introduce = LocalizedStr.tr("Localizable", "introduce")
  /// 请确保【系统设置->扩展】里开启了 ImageGotcha
  static let macTutorial = LocalizedStr.tr("Localizable", "macTutorial")
  /// 无图片
  static let noPhoto = LocalizedStr.tr("Localizable", "noPhoto")
  /// 好的
  static let ok = LocalizedStr.tr("Localizable", "ok")
  /// 打开 Safari
  static let openSafari = LocalizedStr.tr("Localizable", "openSafari")
  /// 开源协议
  static let opensource = LocalizedStr.tr("Localizable", "opensource")
  /// 图片
  static let picture = LocalizedStr.tr("Localizable", "Picture")
  /// 保存
  static let save = LocalizedStr.tr("Localizable", "save")
  /// 保存失败
  static let saveFail = LocalizedStr.tr("Localizable", "saveFail")
  /// 保存图片
  static let savePhoto = LocalizedStr.tr("Localizable", "savePhoto")
  /// 保存成功
  static let saveSuccess = LocalizedStr.tr("Localizable", "saveSuccess")
  /// 保存到App内相册
  static let saveToPrivateAlbum = LocalizedStr.tr("Localizable", "saveToPrivateAlbum")
  /// 保存到系统相册
  static let saveToSystemAlbum = LocalizedStr.tr("Localizable", "saveToSystemAlbum")
  /// 选择
  static let select = LocalizedStr.tr("Localizable", "select")
  /// 全选
  static let selectAll = LocalizedStr.tr("Localizable", "selectAll")
  /// 分享
  static let share = LocalizedStr.tr("Localizable", "share")
  /// 点击分享按钮
  static let t2 = LocalizedStr.tr("Localizable", "t2")
  /// 在最下面一行选择更多
  static let t3 = LocalizedStr.tr("Localizable", "t3")
  /// 启用 ImageGotcha
  static let t4 = LocalizedStr.tr("Localizable", "t4")
  /// 点击 ImageGotcha 图标来使用
  static let t5 = LocalizedStr.tr("Localizable", "t5")
  /// 教程
  static let tutorial = LocalizedStr.tr("Localizable", "tutorial")
  /// 视频
  static let video = LocalizedStr.tr("Localizable", "Video")
}

extension LocalizedStr {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
