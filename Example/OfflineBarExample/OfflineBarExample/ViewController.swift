//
//  ViewController.swift
//  OfflineBarExample
//
//  Created by Teruto Yamasaki on 2016/09/27.
//  Copyright © 2016年 Teruto Yamasaki. All rights reserved.
//

import UIKit
import OfflineBar

class ViewController: UIViewController {
    
    private var offlineBar: OfflineBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.offlineBar = OfflineBar(addedTo: self, style: .reload)
    }
}
