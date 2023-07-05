//
//  TabBarViewController.swift
//  misedoko
//
//  Created by saki on 2023/07/01.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        selectedIndex = 1
    }
    
    
}
