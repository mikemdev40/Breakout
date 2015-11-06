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
        static let topIndentBeforeFirstRow: CGFloat = 30
        
    }
    
    // MARK: Variables
    @IBOutlet weak var gameView: UIView!
    
    var blocksPerRow: CGFloat = 5
    var numberOfRows: CGFloat = 3
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    var blocks = [UIView?]()
    
    var boxSize: CGSize {
        let w = (gameView.bounds.size.width - (horizontalSpacing * (blocksPerRow + 1))) / blocksPerRow
        let h = w * Constants.heightToWidthRatio
        let size = CGSize(width: w, height: h)
        return size
    }
    
    // MARK: Methods
    func updateUI() {
        var index = 0
        for row in 1...Int(numberOfRows) {
            for block in 1...Int(blocksPerRow) {
                let xLocation = horizontalSpacing * CGFloat(block) + boxSize.width * (CGFloat(block) - 1)
                let yLocation = verticalSpacing * CGFloat(row) + boxSize.height * (CGFloat(row) - 1) + Constants.topIndentBeforeFirstRow
                blocks[index]!.frame.size = boxSize  // we can adjust settings on an array of subviews because classes are REFERENCE types so when we change one of the properties of the subview in the blocks array, we are changing the property of the REAL subview (not a copy of it)!!!
                blocks[index]!.frame.origin = CGPoint(x: xLocation, y: yLocation)
                blocks[index]!.backgroundColor = UIColor.redColor()
        //CODE BELOW NOT NEEDED since we can use the blocks array to access the subview properties, since classes are REFERENCE TYPES; however, the code below works just fine!!
                //gameView.subviews[index].frame.size = boxSize
                //gameView.subviews[index].frame.origin = CGPoint(x: xLocation, y: yLocation)
                //gameView.subviews[index].backgroundColor = UIColor.redColor()
                index++
            }
        }

    }
    
    func setupBoxes() {
        for var count = 1; count <= Int(numberOfRows * blocksPerRow); ++count {
            let block = UIView()
            gameView.addSubview(block)
            blocks.append(block)
        }
//        for var rowCount = 1; rowCount <= Int(numberOfRows); ++rowCount {
//            for var boxCount = 1; boxCount <= Int(boxesPerRow); ++boxCount {
//                let xLocation = horizontalSpacing * CGFloat(boxCount) + boxSize.width * (CGFloat(boxCount) - 1)
//                let yLocation = verticalSpacing * CGFloat(rowCount) + boxSize.height * (CGFloat(rowCount) - 1) //+ Constants.topIndentBeforeFirstRow
//                let boxOrigin = CGPoint(x: xLocation, y: yLocation)
//                let block = UIView(frame: CGRect(origin: boxOrigin, size: boxSize))
//                gameView.addSubview(block)
//                blocks.append(block)
//            }
//        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoxes()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
       // print("switched! \(gameView.bounds)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
      //  print("viewDidLayout \(gameView.bounds)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}
