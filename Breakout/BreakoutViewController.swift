//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

struct BallNotification {
    static let outNotification = "ball is out of bounds"
}

class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {

    // MARK: Constants
    private struct Constants {
        static let heightToWidthRatio: CGFloat = 2/3
        static let topIndentBeforeFirstRow: CGFloat = 20
        static let topPortionOfScreenForBlocks: CGFloat = 0.5
        static let paddleHeight: CGFloat = 15
        static let ballSize: CGFloat = 5
        static let circleToBallRatio: CGFloat = 1
    }
    
    // MARK: Adjustable Variables
    var blocksPerRow: CGFloat = 6
    var numberOfRows: CGFloat = 4
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    var paddleWidth: CGFloat = 75
    
    // MARK: Variables
    @IBOutlet weak var gameView: GameView! {
        didSet {
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTap:"))
        }
    }
    
    var blocks = [String: UIView]()
    var paddle = UIView()
    var ball = UIView()
    var animatorNotSet = true
    var behavior = BreakoutBehavior()
    
    var ballCenter = CGPoint() {
        didSet {
            let path = UIBezierPath(arcCenter: ballCenter, radius: (Constants.ballSize * Constants.circleToBallRatio), startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
            gameView.placeCircle("ball", circle: path)
        }
    }
    
    lazy var animator: UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        return lazyAnimator
    }()
    
    private var blockSize: CGSize {
        let w = (gameView.bounds.size.width - (horizontalSpacing * (blocksPerRow + 1))) / blocksPerRow
        let h = min(w * Constants.heightToWidthRatio, (gameView.bounds.size.height * Constants.topPortionOfScreenForBlocks - (verticalSpacing * (numberOfRows + 1))) / numberOfRows)
        let size = CGSize(width: w, height: h)
        return size
    }
    
    lazy var bounciness: UIDynamicItemBehavior = {
        let lazyBounciness = UIDynamicItemBehavior()
        lazyBounciness.allowsRotation = false
        lazyBounciness.elasticity = 1
        lazyBounciness.resistance = 0
        lazyBounciness.friction = 0
        return lazyBounciness
    }()
    
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
                //animator.updateItemUsingCurrentState(paddle)
            }
        case .Ended: break
        default: break
        }
    }
    
    func didTap(gesture: UIGestureRecognizer) {
        behavior.pushBall(ball)
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let collidedBoundary = identifier as? String {
            //print("collided with \(collidedBoundary)")
            if let collidedInt = Int(collidedBoundary) {
                let collided = "\(collidedInt)"
                if let block = blocks[collided] {
                    behavior.removeBoundaryWithIdentifier(collided)
                    behavior.removeItem(block)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        block.backgroundColor = UIColor.blueColor()
                        block.alpha = 0
                        },
                        completion: { (Bool) -> Void in
                         //   print("block removed: \(collided)")
                            block.removeFromSuperview()
                            self.blocks[collided] = nil
                    })
                }
            }
        }
    }
    
    private func updateBlockPositions() {
        var index = 0
        var numboxes = 0
        for row in 1...Int(numberOfRows) {
            for block in 1...Int(blocksPerRow) {
                let xLocation = horizontalSpacing * CGFloat(block) + blockSize.width * (CGFloat(block) - 1)
                let yLocation = verticalSpacing * CGFloat(row) + blockSize.height * (CGFloat(row) - 1) + Constants.topIndentBeforeFirstRow
                if let block = blocks["\(index)"] {
                    block.frame.size = blockSize
                    block.frame.origin = CGPoint(x: xLocation, y: yLocation)
                    block.backgroundColor = UIColor.redColor()
                    let boxPath = UIBezierPath(rect: CGRect(origin: block.frame.origin, size: block.frame.size))
                    behavior.removeBoundary("\(index)")
                    behavior.addBoundary("\(index)", path: boxPath)
                    numboxes++
                }
                index++
            }
        }
      //  print("\(numboxes) updated")
    }
    
    private func placeBall() {
        let xLocation = gameView.frame.midX - Constants.ballSize / 2
        let yLocation = gameView.frame.maxY - paddle.frame.height - Constants.ballSize
        ball.frame.size.height = Constants.ballSize
        ball.frame.size.width = Constants.ballSize
        ball.frame.origin = CGPoint(x: xLocation, y: yLocation)
    }
    
    private func placePaddle() {
        let xLocation = gameView.frame.midX - paddleWidth / 2
        let yLocation = gameView.frame.maxY - paddle.frame.height
        paddle.frame.size.height = Constants.paddleHeight
        paddle.frame.size.width = paddleWidth
        paddle.frame.origin = CGPoint(x: xLocation, y: yLocation)
        paddle.backgroundColor = UIColor.greenColor()
        behavior.removeBoundary("paddle")
        behavior.addBoundary("paddle", path: createBoundary(paddle))
    }
    
    private func setupBoxes() {
        var index = 0
        for var count = 1; count <= Int(numberOfRows * blocksPerRow); ++count {
            let block = UIView()
            gameView.addSubview(block)
            blocks["\(index)"] = block
            index++
        }
    }
    
    private func createBoundary(view: UIView) -> (UIBezierPath) {
        let path = UIBezierPath(rect: CGRect(origin: view.frame.origin, size: view.frame.size))
        return path
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoxes()
        let center = NSNotificationCenter.defaultCenter()
        let notificationQueue = NSOperationQueue.mainQueue()
        let receiver = behavior
        center.addObserverForName(BallNotification.outNotification, object: receiver, queue: notificationQueue) { (NSNotification) -> Void in
            print("OUT!")
        }
        
        gameView.addSubview(paddle)
        gameView.addSubview(ball)
        behavior.bounceCollider.collisionDelegate = self
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
       // print("switched! \(gameView.bounds)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        behavior.removeBoundary("leftwall")
        behavior.removeBoundary("topwall")
        behavior.removeBoundary("rightwall")
    //    behavior.removeBoundary("bottomwall")
        animator.updateItemUsingCurrentState(gameView)
      //  print(behavior.bounceCollider.boundaryIdentifiers)
        placePaddle()
        updateBlockPositions()
        behavior.removeItemFromBehaviors(ball)
        bounciness.removeItem(ball)
        placeBall()
        ballCenter = ball.frame.origin
        behavior.addBallToBehaviors(ball)
        bounciness.addItem(ball)
        behavior.addBoundary("leftwall", start: gameView.frame.origin, end: CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        behavior.addBoundary("topwall", start: gameView.frame.origin, end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        behavior.addBoundary("rightwall", start: CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y), end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
    //    behavior.addBoundary("bottomwall", start: CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY), end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if animatorNotSet {
            animator.removeAllBehaviors()
            animator.addBehavior(behavior)
            animator.addBehavior(bounciness)
            bounciness.action = {
                self.ballCenter = self.ball.center
               // print(self.ballCenter)
            }
            animatorNotSet = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }

}
