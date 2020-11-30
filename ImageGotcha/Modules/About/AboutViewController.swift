//
//  AboutViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/1.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit
import MessageUI

fileprivate enum AboutData {
    case share, feedback, opensource
    
    var description: String {
        switch self {
        case .share: return LocalizedStr.share
        case .feedback: return LocalizedStr.feedback
        case .opensource: return LocalizedStr.opensource
        }
    }
    
    static let aboutDatas: [AboutData] = [.share, .feedback, .opensource]
}


class AboutViewController: UIViewController {
    
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let myMail = "hansenhs21@live.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedStr.about
        appNameLabel.text = "ImageGotcha " + AppState.version()
        logoImageView.layer.cornerRadius = 8
        logoImageView.layer.masksToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AboutData.aboutDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = AboutData.aboutDatas[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = AboutData.aboutDatas[indexPath.row]
        switch type {
        case .share:
            let appUrl = URL(string: "https://itunes.apple.com/app/id1384107130")
            let objectsToShare: [Any] = ["ImageGotcha", appUrl!]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.present(activityViewController, animated: true, completion: nil)
            } else {
                let popover = activityViewController.popoverPresentationController
                if (popover != nil){
                    popover?.sourceView = self.view
                    popover?.sourceRect = self.view.frame
                    popover?.permittedArrowDirections = .any
                    self.present(activityViewController, animated: true, completion: nil)
                }
            }
            
        case .opensource:
            self.navigationController?.pushViewController(OpenSourceViewController(), animated: true)
            
        case .feedback:
            sendEmail()
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension AboutViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            controller.setSubject("ImageGotcha App Feedback")
            controller.setToRecipients([myMail]) //设置收件人
            controller.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkText]
            self.present(controller, animated: true, completion: nil)
            
        } else {
            let mail = "mailto://" + myMail
            guard let mailUrl = URL(string: mail) else { return }
            UIApplication.shared.open(mailUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    //发送邮件代理方法
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result{
        case .sent:
            dPrint("邮件已发送")
        case .cancelled:
            dPrint("邮件已取消")
        case .saved:
            dPrint("邮件已保存")
        case .failed:
            dPrint("邮件发送失败")
        @unknown default:
            break
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
