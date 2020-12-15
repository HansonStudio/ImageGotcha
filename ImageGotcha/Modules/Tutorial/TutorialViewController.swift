//
//  TutorialViewController.swift
//  ImageGotcha
//
//  Created by Hanson on 2018/5/12.
//  Copyright © 2018年 HansonStudio. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var t1: UILabel!
    @IBOutlet weak var t2: UILabel!
    @IBOutlet weak var t5: UILabel!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var screenShotImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedStr.tutorial
        t1.text = LocalizedStr.openSafari
        t2.text = LocalizedStr.t2
        t5.text = LocalizedStr.t5
        #if targetEnvironment(macCatalyst)
        actionImageView.image = Asset.app.image
        screenShotImageView.image = Asset.screenshotMac.image
        introduceLabel.text = LocalizedStr.introduce + " (\(LocalizedStr.macTutorial))"
        #else
        introduceLabel.text = LocalizedStr.introduce
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
