//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController {

    // MARK: Variables
    @IBOutlet weak var gameView: UIView!
    
    var boxesPerRow: CGFloat {
        return 5
    }
    
    var numberOfRows: CGFloat {
        return 3
    }
    
    var boxSize: CGSize {
        let w = gameView.bounds.width / (boxesPerRow + 3)
        let h = gameView.bounds.width * 2/3
        let size = CGSize(width: w, height: h)
        return size
    }
    
    // MARK: Methods
    func updateUI() {
        let boxFrame = CGRect(origin: CGPointZero, size: boxSize)
        let block = UIView(frame: boxFrame)
        gameView.addSubview(block)
        block.backgroundColor = UIColor.brownColor()
    }
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillLayoutSubviews() {
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}
