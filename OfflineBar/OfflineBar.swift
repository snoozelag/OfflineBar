//
//  OfflineBar.swift
//  OfflineBar
//
//  Created by Teruto Yamasaki on 2016/09/27.
//  Copyright © 2016年 Teruto Yamasaki. All rights reserved.
//

import UIKit
import Reachability

@objc public protocol OfflineBarDelegate {
    
    // Display
    
    @objc optional func offlineBarWillShow(_ offlineBar: OfflineBar)
    @objc optional func offlineBarDidShow(_ offlineBar: OfflineBar)
    @objc optional func offlineBarWillHide(_ offlineBar: OfflineBar)
    @objc optional func offlineBarDidHide(_ offlineBar: OfflineBar)
    
    // Button Action
    
    @objc optional func offlineBar(_ offlineBar: OfflineBar, didTappedCloseButton button: UIButton)
    @objc optional func offlineBar(_ offlineBar: OfflineBar, didTappedReloadButton button: UIButton)
    
}

public enum OfflineBarStyle {
    case reload // reload
    case close // close
}

@IBDesignable
open class OfflineBar: UIView {
    
    private enum OfflineBarState: Int {
        case hidden
        case showAnimating
        case offline
        case connecting
        case connected
        case hideAnimating
    }
    
    weak open var delegate: OfflineBarDelegate?
    
    // view
    open private(set) var baseView: UIView!
    open private(set) var titleLabel: UILabel!
    open private(set) var rightButton: UIButton!
    
    // view param
    open var height: CGFloat = 33
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.height)
    }
    
    // Color
    open var offlineBackgoundColor = UIColor(red: 98/255, green: 104/255, blue: 112/255, alpha: 1.0)
    open var connectingBackgoundColor = UIColor(red: 98/255, green: 104/255, blue: 112/255, alpha: 1.0)
    open var connectedBackgoundColor = UIColor(red: 65/255, green: 187/255, blue: 133/255, alpha: 1.0)
    open var offlineTextColor = UIColor.white
    open var connectingTextColor = UIColor.white
    open var connectedTextColor = UIColor.white
    open var offlineButtonTintColor = UIColor.white
    open var connectingButtonTintColor = UIColor.white
    open var connectedButtonTintColor = UIColor.white
    
    open var offlineText = "Offline"
    open var connectingText = "Connecting..."
    open var connectedText = "Connected"
    
    // flag
    private var style: OfflineBarStyle = .reload
    private var state: OfflineBarState = .hidden
    
    // constraints
    private var heightConstraints: [NSLayoutConstraint]!
    private var showStateConstraints: [NSLayoutConstraint]!
    private var hideStateConstraints: [NSLayoutConstraint]!
    
    // MARK: - Initializer
    
    public init(addedTo viewController: UIViewController, style: OfflineBarStyle) {
        self.style = style
        super.init(frame: .zero)
        self.commonInit()
        self.added(to: viewController)
        self.addObserverReachability()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
        self.addObserverReachability()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.addObserverReachability()
    }
    
    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.isHidden = true
        self.setupSubviews()
        self.addConstraintBaseView()
    }
    
    // MARK: -  Configure Views
    
    private func setupSubviews() {
        self.baseView = self.makeBaseView()
        self.titleLabel = self.makeTitleLabel()
        self.rightButton = self.makeRightButton()
        self.baseView.addSubview(self.titleLabel)
        self.baseView.addSubview(self.rightButton)
        self.rightButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightButton(30)]",
                                                                       options: NSLayoutFormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: ["rightButton": self.rightButton]))
        self.rightButton.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[rightButton(30)]",
                                                                       options: NSLayoutFormatOptions(rawValue: 0),
                                                                       metrics: nil,
                                                                       views: ["rightButton": self.rightButton]))
        self.baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=16,<=47)-[titleLabel]-8-[rightButton]-8-|",
                                                                    options: NSLayoutFormatOptions(rawValue: 0),
                                                                    metrics: nil,
                                                                    views: ["titleLabel": self.titleLabel, "rightButton": self.rightButton]))
        NSLayoutConstraint(item: self.titleLabel, attribute: .centerY, relatedBy: .equal, toItem: self.baseView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: self.rightButton, attribute: .centerY, relatedBy: .equal, toItem: self.baseView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        self.addSubview(self.baseView)
    }
    
    private func addConstraintBaseView() {
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[baseView]-0-|",
                                                           options: NSLayoutFormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["baseView": self.baseView]))
        
        NSLayoutConstraint(item: self.baseView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.height).isActive = true
        self.showStateConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[baseView]",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: ["baseView": self.baseView])
        
        self.hideStateConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-hideStateY-[baseView]",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: ["hideStateY": -self.height],
                                                                   views: ["baseView": self.baseView])
        self.addConstraints(self.hideStateConstraints) // start view position
    }
    
    private func added(to viewController: UIViewController) {
        viewController.view.addSubview(self)
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[self]-0-|",
                                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["self": self]))
        
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-0-[self]",
                                                                          options: NSLayoutFormatOptions(rawValue: 0),
                                                                          metrics: nil,
                                                                          views: ["topLayoutGuide": viewController.topLayoutGuide, "self": self])
        )
    }
    
    
    // MARK: - Notification Action
    
    private func addObserverReachability() {
        Reachability.forInternetConnection().startNotifier()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OfflineBar.reachabilityChanged(_:)),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OfflineBar.applicationWillEnterForeground(_:)),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        
        if Reachability.forInternetConnection().isReachable() == false {
            self.show()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reachabilityChanged(_ notification: NSNotification) {
        switch self.style {
        case .reload:
            self.switchConnectivityForInternetConection()
        case .close:
            self.switchVisibilityForInternetConection()
        }
    }
    
    func applicationWillEnterForeground(_ notification: NSNotification) {
        switch self.style {
        case .reload:
            self.switchConnectivityForInternetConection()
        case .close:
            self.switchVisibilityForInternetConection()
        }
    }
    
    func switchConnectivityForInternetConection() {
        guard self.state == .hidden || self.state == .offline else { return }
        if Reachability.forInternetConnection().isReachable() {
            self.connect()
        } else {
            self.show()
        }
    }
    
    func switchVisibilityForInternetConection() {
        guard self.state == .hidden || self.state == .offline || self.state == .connected else { return }
        if Reachability.forInternetConnection().isReachable() {
            self.setViewsConnectedState()
            self.hide()
        } else {
            self.show()
        }
    }
    
    // MARK: - Show / Hide
    
    open func connect() {
        guard self.state == .offline else { return }
        self.state = .connecting
        self.setViewsConnectingState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if Reachability.forInternetConnection().isReachable() {
                self.state = .connected
                self.setViewsConnectedState()
                self.hide()
            } else {
                self.state = .offline
                self.setViewsOfflineState()
            }
        }
    }
    
    open func show() {
        guard self.state == .hidden else { return }
        self.state = .showAnimating
        self.layoutIfNeeded()
        self.setViewsOfflineState()
        self.isHidden = false
        self.removeConstraints(self.hideStateConstraints)
        self.addConstraints(self.showStateConstraints)
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.delegate?.offlineBarWillShow?(self)
            self.layoutIfNeeded()
        }, completion: { isFinished in
            self.state = .offline
            self.delegate?.offlineBarDidShow?(self)
        })
    }
    
    open func hide() {
        guard self.state == .offline || self.state == .connected else { return }
        self.state = .hideAnimating
        self.layoutIfNeeded()
        self.removeConstraints(self.showStateConstraints)
        self.addConstraints(self.hideStateConstraints)
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.5, delay: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.delegate?.offlineBarWillHide?(self)
            self.layoutIfNeeded()
        }, completion: { isFinished in
            self.state = .hidden
            self.isHidden = true
            self.delegate?.offlineBarDidHide?(self)
        })
    }
    
    // MARK: - Factory
    
    private func makeBaseView() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func makeRightButton() -> UIButton {
        let button = UIButton(frame: .zero)
        let bundle = Bundle(for: OfflineBar.self)
        switch self.style {
        case .reload:
            var image = UIImage(named: "reload", in: bundle, compatibleWith: nil)
            image = image?.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.addTarget(self, action: #selector(OfflineBar.rightButtonDidTap(_:)), for: .touchUpInside)
        case .close:
            var image = UIImage(named: "close", in: bundle, compatibleWith: nil)
            image = image?.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.addTarget(self, action: #selector(OfflineBar.rightButtonDidTap(_:)), for: .touchUpInside)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // MARK: - Set Views State
    
    private func setViewsOfflineState() {
        self.rightButton.isHidden = false
        self.rightButton.tintColor = self.offlineButtonTintColor
        self.titleLabel.text = self.offlineText
        self.titleLabel.textColor = self.offlineTextColor
        self.baseView.backgroundColor = self.offlineBackgoundColor
    }
    
    private func setViewsConnectingState() {
        self.rightButton.isHidden = true
        self.rightButton.tintColor = self.connectingButtonTintColor
        self.titleLabel.text = self.connectingText
        self.titleLabel.textColor = self.connectingTextColor
        self.baseView.backgroundColor = self.connectingBackgoundColor
    }
    
    private func setViewsConnectedState() {
        self.rightButton.isHidden = true
        self.rightButton.tintColor = self.connectedButtonTintColor
        self.titleLabel.text = self.connectedText
        self.titleLabel.textColor = self.connectedTextColor
        self.baseView.backgroundColor = self.connectedBackgoundColor
    }
    
    // MARK: - Button Action
    
    func rightButtonDidTap(_ sender: UIButton) {
        switch self.style {
        case .reload:
            self.delegate?.offlineBar?(self, didTappedReloadButton: sender)
            self.connect()
        case .close:
            self.state = .offline
            self.hide()
            self.delegate?.offlineBar?(self, didTappedCloseButton: sender)
        }
    }
    
}

