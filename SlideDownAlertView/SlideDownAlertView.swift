//
//  SlideDownAlertView.swift
//  SlideDownAlertView
//
//  Created by Teruto Yamasaki on 2016/09/27.
//  Copyright © 2016年 Teruto Yamasaki. All rights reserved.
//

import UIKit

class SlideDownAlertView: UIView {
    
    var moovingView: UIView!
    var messageLabel: UILabel!
    private var showStateConstraints: Array<NSLayoutConstraint>!
    private var hideStateConstraints: Array<NSLayoutConstraint>!
    private var isSetupComplete :Bool = false
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (!self.isSetupComplete) {
            self.isSetupComplete = true
            self.setupViews()
        }
    }
    
    // MARK: - Private Methods
    private func createMoovingView() -> UIView {
        return UIView(frame: CGRect.zero)
    }
    
    private func createMessageLabel() -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = NSTextAlignment.center
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters
        return label
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.isHidden = true
        self.moovingView = self.createMoovingView()
        self.messageLabel = self.createMessageLabel()
        self.moovingView.addSubview(self.messageLabel)
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.moovingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[messageLabel]-0-|",
                                                                options: [],
                                                                metrics: nil,
                                                                views: ["messageLabel":self.messageLabel]))
        let adjustTextVerticalCenterValue: CGFloat = 4
        self.moovingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-value-[messageLabel]-0-|",
                                                                options: [],
                                                                metrics: ["value":adjustTextVerticalCenterValue],
                                                                views: ["messageLabel":self.messageLabel]))
        
        self.addSubview(self.moovingView)
        self.moovingView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[moovingView]-0-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["moovingView":self.moovingView]))
        
        let hideStateY = self.bounds.origin.y - self.bounds.size.height
        self.hideStateConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-hideStateY-[moovingView(height)]",
                                                                   options: [],
                                                                   metrics: ["hideStateY":hideStateY, "height":self.bounds.size.height],
                                                                   views: ["moovingView":self.moovingView])
        let showStateY = self.bounds.origin.y
        self.showStateConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-showStateY-[moovingView(height)]",
                                                                   options: [],
                                                                   metrics: ["showStateY":showStateY, "height":self.bounds.size.height],
                                                                   views: ["moovingView":self.moovingView])
        self.addConstraints(self.hideStateConstraints)
    }

    private func configureViewsOfflineState() {
        self.messageLabel.textAlignment = NSTextAlignment.center;
        self.messageLabel.text = "Offline";
        self.messageLabel.textColor = UIColor.white
        self.moovingView.backgroundColor = UIColor.darkGray
    }
    
    private func configureViewsOnlineState() {
        self.messageLabel.textAlignment = NSTextAlignment.center;
        self.messageLabel.text = "Connected";
        self.messageLabel.textColor = UIColor.white
        self.moovingView.backgroundColor = UIColor.green
    }
    
    // MARK: - Internal Methods
    func showSlideDownAlertView() {
        self.configureViewsOfflineState()
        self.isHidden = false
        self.removeConstraints(self.hideStateConstraints)
        self.addConstraints(self.showStateConstraints)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.layoutIfNeeded()
        })
    }
    
    func hideSlideDownAlertView() {
        self.configureViewsOnlineState()
        self.removeConstraints(self.showStateConstraints)
        self.addConstraints(self.hideStateConstraints)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.layoutIfNeeded()
            }, completion: {(finished) in
            self.isHidden = true
        })
    }

}
