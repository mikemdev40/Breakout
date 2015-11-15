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
        static let ballSpeedSlow: CGFloat = 0.025
        static let ballSpeedNormal: CGFloat = 0.04
        static let ballSpeedFast: CGFloat = 0.055
    }
    
    //MARK: Variables
    
    var numberOfRowsData = Constants.rows //required by protocol
    var blocksPerRowData = Constants.blocks //required by protocol
    var ballMagnitude: CGFloat = Constants.ballSpeedNormal //required by 2nd protocol
    var challengeMode = false
    var breakoutVC = BreakoutViewController()

    @IBOutlet weak var numRowsLabel: UILabel!
    @IBOutlet weak var numBlocksLabel: UILabel!
    @IBOutlet weak var ballSpeedLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func numRowsSlider(sender: UISlider) {
        
        // got the code below from http://stackoverflow.com/questions/27927533/how-to-make-uislider-have-discrete-intervals-for-example-intervals-of-5000 which allows you to set an interval AND update the slider to be discrete
        
        let interval = 1  // since this = 1, don't really need this line, but good to have in case i want to reuse this code at another time
        let numRowsValue = Int(sender.value / Float(interval)) * interval
        sender.value = Float(numRowsValue)  //makes slider discrete

        numRowsLabel.text = String(numRowsValue)
        
        if numberOfRowsData != numRowsValue {
            breakoutVC.didUpdateAnything = true
        }
        
        numberOfRowsData = numRowsValue  //serving as the datasource for breakout VC, this updates value for breakout VC to take
       // print(numberOfRowsData)
    }
    

    @IBAction func blockStepper(sender: UIStepper) {

        let numBlocks = Int(sender.value)
        
        numBlocksLabel.text = String(numBlocks)
        
        if blocksPerRowData != numBlocks {
            breakoutVC.didUpdateAnything = true
        }
        
        blocksPerRowData = numBlocks
    }
    
    @IBAction func challengeSwitch(sender: UISwitch) {
        challengeMode = sender.on
        breakoutVC.didUpdateAnything = true
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

//DELETED ALL THE DEFAULT STUFF THAT CAME WITH THE TABLEVIEWCONTROLLER SUBCLA FILE, SINCE THOSE WERE REALLY FOR DYNAMIC CELLS

}
