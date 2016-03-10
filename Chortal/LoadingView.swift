//
//  LoadingView.swift
//  Chortal
//
//  Created by Christopher Erdos on 3/10/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    func addLoadingViewToView(viewController: UIViewController, loadingText: String) {
        self.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        self.backgroundColor = .lightGrayColor()
        self.alpha = 0.80
        self.layer.cornerRadius = 5
        self.center = viewController.view.center
        
        let label = UILabel(frame: CGRect(x: 30, y: 0, width: 170, height: 30))
        label.text = loadingText
        
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        spinner.startAnimating()
        
        self.addSubview(label)
        self.addSubview(spinner)
        
        viewController.view.addSubview(self)
    }

}
