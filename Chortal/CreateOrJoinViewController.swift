//
//  CreateOrJoinViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/27/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class CreateOrJoinViewController: UIViewController {
    
let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.addLoadingViewToView(self, loadingText: "loading...")
    }
    
    override func viewDidAppear(animated: Bool) {
        isICloudContainerAvailable()
    }
    
}
