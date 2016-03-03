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
        
        //ORDER (0 or 1) depends on the order in which you connect them to the tab bar controller in the stroy board (e.g. if you deleted the connections and then reconnect the settings view controller FIRST, then IT would be viewControllers[0]
        
        viewControllers?[0].tabBarItem.title = "Breakout!"
        viewControllers?[0].tabBarItem.image = UIImage(named: "gameicon")
        viewControllers?[1].tabBarItem.title = "Settings"
        viewControllers?[1].tabBarItem.image = UIImage(named: "settingsicon")
        
    }
}
