//
//  AppDelegate.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit
import CoreMotion

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    struct Motion {
        static let Manager = CMMotionManager()
    }
    
    struct UserSettings {
        static let settings = NSUserDefaults.standardUserDefaults()
        static let numRowsKey = "User Setting: Number of Rows"
        static var blocksPerRowKey = "User Setting: Blocks Per Row"
        static var challengeModeKey = "User Setting: Challenge Mode"
        static var ballSpeedKey = "User Setting: Ball Speed"
    }

}

