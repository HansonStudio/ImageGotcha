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
    @IBOutlet weak var t3: UILabel!
    @IBOutlet weak var t4: UILabel!
    @IBOutlet weak var t5: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedStr.tutorial
        introduceLabel.text = LocalizedStr.introduce
        t1.text = LocalizedStr.openSafari
        t2.text = LocalizedStr.t2
//        t3.text = LocalizedStr.t3
//        t4.text = LocalizedStr.t4
        t5.text = LocalizedStr.t5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
