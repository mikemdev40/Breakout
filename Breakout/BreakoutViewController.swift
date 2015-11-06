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
        static let topIndentBeforeFirstRow: CGFloat = 20
        static let topPortionOfScreenForBlocks: CGFloat = 0.5
        static let paddleHeight: CGFloat = 15
    }
    
    // MARK: Adjustable Variables
    var blocksPerRow: CGFloat = 6
    var numberOfRows: CGFloat = 4
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    var paddleWidth: CGFloat = 75
    
    // MARK: Variables
    @IBOutlet weak var gameView: UIView!
    var blocks = [UIView?]()
    var paddle = UIView()
    
    private var blockSize: CGSize {
        let w = (gameView.bounds.size.width - (horizontalSpacing * (blocksPerRow + 1))) / blocksPerRow
        let h = min(w * Constants.heightToWidthRatio, (gameView.bounds.size.height * Constants.topPortionOfScreenForBlocks - (verticalSpacing * (numberOfRows + 1))) / numberOfRows)
        let size = CGSize(width: w, height: h)
        return size
    }
    
    // MARK: Methods
    private func updateUI() {
        var index = 0
        for row in 1...Int(numberOfRows) {
            for block in 1...Int(blocksPerRow) {
                let xLocation = horizontalSpacing * CGFloat(block) + blockSize.width * (CGFloat(block) - 1)
                let yLocation = verticalSpacing * CGFloat(row) + blockSize.height * (CGFloat(row) - 1) + Constants.topIndentBeforeFirstRow
                blocks[index]!.frame.size = blockSize  // we can adjust settings on an array of subviews because classes are REFERENCE types so when we change one of the properties of the subview in the blocks array, we are changing the property of the REAL subview (not a copy of it)!!!
                
                blocks[index]!.frame.origin = CGPoint(x: xLocation, y: yLocation)  //FRAME, not bounds!!!  it took me two hours to figure out why the blocks weren't printing; don't forget that we have to use FRAME to adjust to the location of the view in the superview!!!!  (see lecture 5 notes)
                
                blocks[index]!.backgroundColor = UIColor.redColor()
       
        //CODE BELOW NOT NEEDED since we can use the blocks array to access the subview properties, since classes are REFERENCE TYPES; however, the code below works just fine!!
                //gameView.subviews[index].frame.size = blockSize
                //gameView.subviews[index].frame.origin = CGPoint(x: xLocation, y: yLocation)
                //gameView.subviews[index].backgroundColor = UIColor.redColor()
                
                index++
            }
        }
    }
    
    private func placePaddle() {
        paddle.frame.size.height = Constants.paddleHeight
        paddle.frame.size.width = paddleWidth
        let xLocation = gameView.frame.midX - paddleWidth / 2
        let yLocation = gameView.frame.maxY - paddle.frame.height
        paddle.frame.origin = CGPoint(x: xLocation, y: yLocation)
        paddle.backgroundColor = UIColor.greenColor()
    }
    
    private func setupBoxes() {
        for var count = 1; count <= Int(numberOfRows * blocksPerRow); ++count {
            let block = UIView()
            gameView.addSubview(block)
            blocks.append(block)
        }
        gameView.addSubview(paddle)
        //blocks.append(paddle)  //NOT added to the blocks array!!!  (duh)
        print(blocks.count)
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
        placePaddle()
        updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}
