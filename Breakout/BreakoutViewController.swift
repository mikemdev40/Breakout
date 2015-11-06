//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController {

    // MARK: Constants
    private struct Constants {
        static let heightToWidthRatio: CGFloat = 2/3
        
    }
    
    // MARK: Variables
    @IBOutlet weak var gameView: UIView!
    
    var boxesPerRow: CGFloat = 5
    var numberOfRows: CGFloat = 3
    var verticalSpacing: CGFloat = 30
    var horizontalSpacing: CGFloat = 30
    var blocks = [UIView?]()
    
    var boxSize: CGSize {
        let w = (gameView.bounds.size.width - (horizontalSpacing * (boxesPerRow + 1))) / boxesPerRow
        let h = w * Constants.heightToWidthRatio
        let size = CGSize(width: w, height: h)
        return size
    }
    
    // MARK: Methods
    func updateUI() {
        for block in blocks {
            
        }
    }
    
    func setupBoxes() {
        
        for var rowCount = 1; rowCount <= Int(numberOfRows); ++rowCount {
            for var boxCount = 1; boxCount <= Int(boxesPerRow); ++boxCount {
                let xLocation = horizontalSpacing * CGFloat(boxCount) + boxSize.width * (CGFloat(boxCount) - 1)
                let yLocation = verticalSpacing * CGFloat(rowCount) + boxSize.height * (CGFloat(rowCount) - 1)
                let boxOrigin = CGPoint(x: xLocation, y: yLocation)
                let block = UIView(frame: CGRect(origin: boxOrigin, size: boxSize))
                block.backgroundColor = UIColor.blueColor()
                gameView.addSubview(block)
                blocks.append(block)
            }
        }
        updateUI()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupBoxes()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}
