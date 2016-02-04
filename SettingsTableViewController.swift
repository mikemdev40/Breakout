//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/11/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit


class SettingsTableViewController: UITableViewController, GameViewDataSource, BallSettingsDataSource {

    //MARK: Default Values
    
    struct Constants {
        static let rows = 4
        static let blocks = 5
        static let challengeMode = false
        static let ballSpeedSlow: CGFloat = 0.025
        static let ballSpeedNormal: CGFloat = 0.04
        static let ballSpeedFast: CGFloat = 0.055
        static let defaultPaddleControl = 0
    }
    
    //MARK: Variables
    
    var numberOfRowsData = Constants.rows //required by protocol
    var blocksPerRowData = Constants.blocks //required by protocol
    var challengeMode = false //required by protocol
    var ballMagnitude: CGFloat = Constants.ballSpeedNormal //required by 2nd protocol
    var breakoutVC = BreakoutViewController()
    var paddleControl = 0

    @IBOutlet weak var numRowsSliderOutlet: UISlider!
    @IBOutlet weak var blocksPerRowOutlet: UIStepper!
    @IBOutlet weak var challengeModeOutlet: UISwitch!
    @IBOutlet weak var ballSpeedOutlet: UIStepper!
    @IBOutlet weak var paddleControlOutlet: UISegmentedControl!
    
    @IBOutlet weak var numRowsLabel: UILabel!
    @IBOutlet weak var numBlocksLabel: UILabel!
    @IBOutlet weak var ballSpeedLabel: UILabel!
    
    //MARK: Actions
    
    
    @IBAction func selectPaddleControl(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            paddleControl = 0
        } else {
            paddleControl = 1
        }
        AppDelegate.UserSettings.settings.setObject(paddleControl, forKey: AppDelegate.UserSettings.paddleControl)
    }
    
    @IBAction func numRowsSlider(sender: UISlider) {
        
        // got the code below from http://stackoverflow.com/questions/27927533/how-to-make-uislider-have-discrete-intervals-for-example-intervals-of-5000 which allows you to set an interval AND update the slider to be discrete
        
        let interval = 1  // since this = 1, don't really need this line, but good to have in case i want to reuse this code at another time
        let numRowsValue = Int(sender.value / Float(interval)) * interval
        sender.value = Float(numRowsValue)  //makes slider discrete

        numRowsLabel.text = String(numRowsValue)
        
        if numberOfRowsData != numRowsValue {
            breakoutVC.didUpdateAnything = true
            AppDelegate.UserSettings.settings.setObject(numRowsValue, forKey: AppDelegate.UserSettings.numRowsKey)
        }
        
        numberOfRowsData = numRowsValue  //serving as the datasource for breakout VC, this updates value for breakout VC to take
    }
    

    @IBAction func blockStepper(sender: UIStepper) {

        let numBlocks = Int(sender.value)
        
        numBlocksLabel.text = String(numBlocks)
        
        if blocksPerRowData != numBlocks {
            breakoutVC.didUpdateAnything = true
            AppDelegate.UserSettings.settings.setObject(numBlocks, forKey: AppDelegate.UserSettings.blocksPerRowKey)
        }
        
        blocksPerRowData = numBlocks
    }
    
    @IBAction func challengeSwitch(sender: UISwitch) {
        challengeMode = sender.on
        breakoutVC.didUpdateAnything = true
        AppDelegate.UserSettings.settings.setObject(challengeMode, forKey: AppDelegate.UserSettings.challengeModeKey)
    }
    
    @IBAction func ballSpeed(sender: UIStepper) {
        let ballSpeed = Int(sender.value)
        switch ballSpeed {
        case 1:
            ballSpeedLabel.text = "Slow"
            ballMagnitude = Constants.ballSpeedSlow
        case 2:
            ballSpeedLabel.text = "Normal"
            ballMagnitude = Constants.ballSpeedNormal
        case 3:
            ballSpeedLabel.text = "Fast"
            ballMagnitude = Constants.ballSpeedFast
        default: break
        }
        //breakoutVC.didUpdateAnything = true
    }

    
    override func viewDidAppear(animated: Bool) {
        breakoutVC.didUpdateAnything = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
    // setup the user's saved values
        numRowsSliderOutlet.value = (AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.numRowsKey) as? Float) ?? Float(Constants.rows)
        numRowsLabel.text = "\(Int(numRowsSliderOutlet.value))"
        numberOfRowsData = Int(numRowsSliderOutlet.value)
        blocksPerRowOutlet.value = (AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.blocksPerRowKey) as? Double) ?? Double(Constants.blocks)
        numBlocksLabel.text = "\(Int(blocksPerRowOutlet.value))"
        blocksPerRowData = Int(blocksPerRowOutlet.value)
        challengeModeOutlet.on = (AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.challengeModeKey) as? Bool) ?? Constants.challengeMode
        challengeMode = challengeModeOutlet.on
        paddleControlOutlet.selectedSegmentIndex = (AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.paddleControl) as? Int) ?? Constants.defaultPaddleControl
        paddleControl = paddleControlOutlet.selectedSegmentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // code below inspired by http://makeapppie.com/2015/02/04/swift-swift-tutorials-passing-data-in-tab-bar-controllers/
        // this allows us to connect the two VCs so that this one can serve as the datasource for the other
        if let bvc = tabBarController?.viewControllers?[0] as? BreakoutViewController {
            breakoutVC = bvc
            breakoutVC.dataSource = self
            breakoutVC.behavior.dataSource = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
