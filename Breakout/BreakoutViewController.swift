//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {

    // MARK: Constants
    private struct Constants {
        static let heightToWidthRatio: CGFloat = 2/3
        static let topIndentBeforeFirstRow: CGFloat = 20
        static let topPortionOfScreenForBlocks: CGFloat = 0.5
        static let paddleHeight: CGFloat = 15
        static let ballSize: CGFloat = 10
    }
    
    // MARK: Adjustable Variables
    var blocksPerRow: CGFloat = 6
    var numberOfRows: CGFloat = 4
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    var paddleWidth: CGFloat = 75
    
    // MARK: Variables
    @IBOutlet weak var gameView: GameView!
    
    var blocks = [UIView?]()
    var paddle = UIView()
    var ball = UIView()
    var animatorNotSet = true
//    lazy var ball: UIView = {
//        let lazyBall = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: Constants.ballSize, height: Constants.ballSize)))
//        return lazyBall
//    }()
    
    lazy var animator: UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return lazyAnimator
    }()
    
    var behavior = BreakoutBehavior()
    
    private var blockSize: CGSize {
        let w = (gameView.bounds.size.width - (horizontalSpacing * (blocksPerRow + 1))) / blocksPerRow
        let h = min(w * Constants.heightToWidthRatio, (gameView.bounds.size.height * Constants.topPortionOfScreenForBlocks - (verticalSpacing * (numberOfRows + 1))) / numberOfRows)
        let size = CGSize(width: w, height: h)
        return size
    }
    
    // MARK: Methods
    @IBAction func scrollPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began: fallthrough
        case .Changed:
            let translation = gesture.translationInView(gameView)
            if (paddle.frame.origin.x + translation.x) > gameView.frame.minX && (paddle.frame.origin.x + paddleWidth + translation.x) < gameView.frame.maxX {
                paddle.frame.origin.x += translation.x
                gesture.setTranslation(CGPointZero, inView: gameView)
                behavior.removeBoundary("paddle")
                behavior.addBoundary("paddle", path: createBoundary(paddle))
                // animator.updateItemUsingCurrentState(paddle)
            }
        case .Ended: break
            
        default: break
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        print("collision")
    }
    
    private func updateBlockPositions() {
        var index = 0
        for row in 1...Int(numberOfRows) {
            for block in 1...Int(blocksPerRow) {
                let xLocation = horizontalSpacing * CGFloat(block) + blockSize.width * (CGFloat(block) - 1)
                let yLocation = verticalSpacing * CGFloat(row) + blockSize.height * (CGFloat(row) - 1) + Constants.topIndentBeforeFirstRow
                blocks[index]!.frame.size = blockSize
                blocks[index]!.frame.origin = CGPoint(x: xLocation, y: yLocation)
                blocks[index]!.backgroundColor = UIColor.redColor()
                index++
            }
        }
    }
    
    private func placeBall() {
        let xLocation = gameView.frame.midX - Constants.ballSize / 2
        let yLocation = gameView.frame.maxY - paddle.frame.height - Constants.ballSize
        ball.frame.size.height = Constants.ballSize
        ball.frame.size.width = Constants.ballSize
        ball.frame.origin = CGPoint(x: xLocation, y: yLocation)
        ball.backgroundColor = UIColor.blackColor()
    }
    
    private func placePaddle() {
        let xLocation = gameView.frame.midX - paddleWidth / 2
        let yLocation = gameView.frame.maxY - paddle.frame.height
        paddle.frame.size.height = Constants.paddleHeight
        paddle.frame.size.width = paddleWidth
        paddle.frame.origin = CGPoint(x: xLocation, y: yLocation)
        paddle.backgroundColor = UIColor.greenColor()
        behavior.addBoundary("paddle", path: createBoundary(paddle))
    }
    
    private func setupBoxes() {
        for var count = 1; count <= Int(numberOfRows * blocksPerRow); ++count {
            let block = UIView()
            gameView.addSubview(block)
            blocks.append(block)
        }
    }
    
    private func addWallBoundary() -> (name: String, path: UIBezierPath) {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        path.addLineToPoint(CGPointZero)
        path.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        path.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
        path.addLineToPoint(CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        path.addLineToPoint(CGPointZero)
        path.moveToPoint(CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        path.closePath()
        return ("wall", path)
    }
    
    private func createBoundary(view: UIView) -> (UIBezierPath) {
        let path = UIBezierPath(rect: CGRect(origin: view.frame.origin, size: view.frame.size))
        return path
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoxes()
        gameView.addSubview(paddle)
        gameView.addSubview(ball)
        animator.delegate = self
        behavior.bounceCollider.collisionDelegate = self
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
       // print("switched! \(gameView.bounds)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        placePaddle()
        placeBall()
        updateBlockPositions()
   //     behavior.addBoundary(addWallBoundary().name, path: addWallBoundary().path)
        //animator.updateItemUsingCurrentState(gameView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if animatorNotSet {
            animator.addBehavior(behavior)  //added HERE because when it was added to viewDidLoad, the gameView size that was captured was the frame of the gameView that DIDN'T include the tab bar at the bottom
            behavior.addBallToBehaviors(ball)
     //       behavior.addPaddleToBehaviors(paddle)
            animatorNotSet = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}
