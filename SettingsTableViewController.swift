//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/11/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

//--- NOTES ---
// - DISABLED scrolling of the tableView, because that changed the frame of the OTHER viewcontroller too, and caused the game to end early (under Attributes Inspector, unchecked the "scrolling enabled" box)

import UIKit

class SettingsTableViewController: UITableViewController, GameViewDataSource {

    //MARK: Default Values
    
    struct Defaults {
        static let rows = 4
        static let blocks = 5
    }
    
    //MARK: Variables
    
    var numberOfRowsData = Defaults.rows //required by protocol
    var blocksPerRowData = Defaults.blocks //required by protocol
    var didUpdateAnything = false
    
    @IBOutlet weak var numRowsLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func numRowsSlider(sender: UISlider) {
        
        // got the code below from http://stackoverflow.com/questions/27927533/how-to-make-uislider-have-discrete-intervals-for-example-intervals-of-5000 which allows you to set an interval AND update the slider to be discrete
        
        let interval = 1  // since this = 1, don't really need this line, but good to have in case i want to reuse this code at another time
        let numRowsValue = Int(sender.value / Float(interval)) * interval
        sender.value = Float(numRowsValue)  //makes slider discrete

        numRowsLabel.text = String(numRowsValue)
        
        if numberOfRowsData != numRowsValue {
            didUpdateAnything = true
        }
        
        numberOfRowsData = numRowsValue  //serving as the datasource for breakout VC, this updates value for breakout VC to take
       // print(numberOfRowsData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // got the code below from http://makeapppie.com/2015/02/04/swift-swift-tutorials-passing-data-in-tab-bar-controllers/
        // this allows us to connect the two VCs so that this one can serve as the datasource for the other
        if let bvc = tabBarController?.viewControllers?[0] as? BreakoutViewController {
            bvc.dataSource = self
            print("datasource connected")
        }
        didUpdateAnything = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//DELETED ALL THE DEFAULT STUFF THAT CAME WITH THE TABLEVIEWCONTROLLER SUBCLA FILE, SINCE THOSE WERE REALLY FOR DYNAMIC CELLS

}
