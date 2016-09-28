//
//  ViewController.swift
//  SlideDownAlertView
//
//  Created by Teruto Yamasaki on 2016/09/27.
//  Copyright © 2016年 Teruto Yamasaki. All rights reserved.
//

import UIKit
import Reachability

class ViewController: UIViewController {
    
    let reachability: Reachability = Reachability.forInternetConnection()
    
//    @IBOutlet weak var slideDownAlertView: SlideDownAlertView! // Storyboard
    let slideDownAlertView :SlideDownAlertView = SlideDownAlertView(frame: CGRect.zero)// Programatically

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "title"
        // ---Programatically---
        self.slideDownAlertView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.slideDownAlertView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[slideDownAlertView]-0-|",
                                                                options: [],
                                                                metrics: nil,
                                                                views: ["slideDownAlertView":self.slideDownAlertView]))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-0-[slideDownAlertView(33)]",
                                                                options: [],
                                                                metrics: nil,
                                                                views: ["topLayoutGuide":self.topLayoutGuide, "slideDownAlertView":self.slideDownAlertView]))
        // ---------------------
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.reachabilityChanged(notification:)),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reachabilityChanged(notification: NSNotification) {
        if self.reachability.isReachable() {
            print("Service avalaible")
            
            self.slideDownAlertView.hideSlideDownAlertView()
        } else {
            print("No service avalaible")
            
            self.slideDownAlertView.showSlideDownAlertView()
        }
    }
}

