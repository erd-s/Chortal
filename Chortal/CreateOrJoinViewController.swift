//
//  CreateOrJoinViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/27/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class CreateOrJoinViewController: UIViewController, UIGestureRecognizerDelegate {
    
let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.addLoadingViewToView(self, loadingText: "loading...")
        
        let tap = UITapGestureRecognizer(target: self, action: "hideLoading")
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        isICloudContainerAvailable()
    }
    
    func hideLoading() {
        if loadingView.hidden {
            loadingView.hidden = false
        } else {
            loadingView.hidden = true
        }
    }
    
    
    
    //--------Remember:
    //hide and unhide work while the hidden command is set in the view controller, test with admin home.
}
