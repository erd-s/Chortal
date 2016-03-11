//
//  LoadingView.swift
//  Chortal
//
//  Created by Christopher Erdos on 3/10/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class LoadingView: UIView, UIGestureRecognizerDelegate {

    func addLoadingViewToView(viewController: UIViewController, loadingText: String) {
        self.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        self.backgroundColor = .lightGrayColor()
        self.alpha = 0.90
        self.layer.cornerRadius = 5
        self.center = viewController.view.center
        
        let label = UILabel(frame: CGRect(x: 30, y: 0, width: 170, height: 30))
        label.text = loadingText
        label.textAlignment = .Center
        label.textColor = .whiteColor()
        
        
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        spinner.startAnimating()
        
        self.addSubview(label)
        self.addSubview(spinner)
        
        let tap = UITapGestureRecognizer(target: self, action: "changeColor")
        self.addGestureRecognizer(tap)
        tap.delegate = self
        
        viewController.view.addSubview(self)
        viewController.view.bringSubviewToFront(self)
        viewController.view.layoutIfNeeded()
    }

    func changeColor() {
        let randRed = CGFloat(arc4random_uniform(100))/100
        let randGreen = CGFloat(arc4random_uniform(100))/100
        let randBlue = CGFloat(arc4random_uniform(100))/100
        self.backgroundColor = UIColor(red: randRed, green: randGreen, blue: randBlue, alpha: 0.8)
    }
}
