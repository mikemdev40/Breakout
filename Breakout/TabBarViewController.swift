//
//  TabBarViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers?[0].tabBarItem.title = "Breakout!"
//        viewControllers?[0].tabBarItem.image = UIImage(named: "breakout")
        viewControllers?[1].tabBarItem.title = "Settings"
//        viewControllers?[1].tabBarItem.image = UIImage(named: "settings")
        
        
    }
}
