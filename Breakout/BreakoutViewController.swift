//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

protocol GameViewDataSource {
    var numberOfRowsData: Int { get }
    var blocksPerRowData: Int { get }
    var challengeMode: Bool { get }
}

class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {
    
    // MARK: Constants
    private struct Constants {
        static let heightToWidthRatio: CGFloat = 2/3
        static let topIndentBeforeFirstRow: CGFloat = 20
        static let topPortionOfScreenForBlocks: CGFloat = 0.5
        static let paddleHeight: CGFloat = 15
        static let ballRadius: CGFloat = 5
        static let circleToBallRatio: CGFloat = 1
        static let defaultRows = 4
        static let defaultBlocks = 5
        static let paddleFromBottomOffset: CGFloat = 1
    }
    
    private enum gameOver {
        case Win
        case Lose
    }
    
    // MARK: Adjustable Variables
    var blocksPerRow: CGFloat {
        let blocks = dataSource?.blocksPerRowData ?? Constants.defaultBlocks
        return CGFloat(blocks)
    }
    
    var numberOfRows: CGFloat {
        let blocks = dataSource?.numberOfRowsData ?? Constants.defaultRows
        return CGFloat(blocks)
    }
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    var paddleWidth: CGFloat = 75
    
    // MARK: Variables
    var dataSource: GameViewDataSource?
    
    @IBOutlet weak var gameView: GameView! {
        didSet {
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTap:"))
        }
    }
    
    var didUpdateAnything = false
    var blocks = [String: UIView]()
    var blocksChallengeSetting = [String: Bool]()
    var paddle = UIView()
    var ball = UIView()
    var animatorNotSet = true
    
    let paddleGravity = UIGravityBehavior()
    let paddleCollider = UICollisionBehavior()
    
    var behavior = BreakoutBehavior()
    var ballCenter = CGPoint() {
        didSet {
            let path = UIBezierPath(arcCenter: ballCenter, radius: (Constants.ballRadius * Constants.circleToBallRatio), startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
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
                animator.updateItemUsingCurrentState(paddle)
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
            if let collidedInt = Int(collidedBoundary) {
                let collided = "\(collidedInt)"
                if let block = blocks[collided] {
                    if blocksChallengeSetting[collided] == true {
                        block.backgroundColor = UIColor.yellowColor()
                        blocksChallengeSetting[collided] = false
                    } else {
                        behavior.removeBoundaryWithIdentifier(collided)
                        behavior.removeItem(block)
                        blocks[collided] = nil
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            block.backgroundColor = UIColor.blueColor()
                            block.alpha = 0
                            },
                            completion: { [unowned self] (Bool) -> Void in
                            //  print("block removed: \(collided)")
                                block.removeFromSuperview()
                                if self.blocks.count == 0 {
                                    self.showGameOver(.Win)
                                    self.behavior.removeBoundary("bottomwall")
                                }
                        })
                    }
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
    }
    
    private func placeBall() {
        let xLocation = gameView.frame.midX - Constants.ballRadius
        let yLocation = gameView.frame.maxY - paddle.frame.height - 2 * Constants.ballRadius
        ball.frame.size = CGSize(width: Constants.ballRadius * 2, height: Constants.ballRadius * 2)
        ball.frame.origin = CGPoint(x: xLocation, y: yLocation)
        //ball.backgroundColor = UIColor.blackColor()
    }
    
    private func placePaddle() {
        let xLocation = gameView.frame.midX - paddleWidth / 2
        let yLocation = gameView.frame.maxY - paddle.frame.height - Constants.paddleFromBottomOffset
        paddle.frame.size.height = Constants.paddleHeight
        paddle.frame.size.width = paddleWidth
        paddle.frame.origin = CGPoint(x: xLocation, y: yLocation)
        paddle.backgroundColor = UIColor.greenColor()
    }
    
    private func setupBoxes() {
        var index = 0
        for var count = 1; count <= Int(numberOfRows * blocksPerRow); ++count {
            let block = UIView()
            gameView.addSubview(block)
            blocks["\(index)"] = block
            if dataSource?.challengeMode == true {
                blocksChallengeSetting["\(index)"] = true
            } else {
                blocksChallengeSetting["\(index)"] = false
            }
            index++
        }
    }
    
    private func showGameOver(end: gameOver) {
        if presentedViewController == nil {
            switch end {
            case .Lose:
                let alert = UIAlertController(title: "Game Over", message: "Try again?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "End", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Replay", style: .Cancel, handler: { (UIAlertAction) -> Void in
                    self.reset()
                    self.clearAnimator()
                    self.prepareUI()
                    self.setupAnimator()
                }))
                presentViewController(alert, animated: true, completion: nil)
            case .Win:
                let alert = UIAlertController(title: "YOU WIN!", message: "Play again?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "End", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Replay", style: .Cancel, handler: { (UIAlertAction) -> Void in
                    self.reset()
                    self.clearAnimator()
                    self.prepareUI()
                    self.setupAnimator()
                }))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func reset() {
        for (_, block) in blocks {
            block.removeFromSuperview()
        }
        blocks.removeAll()
        blocksChallengeSetting.removeAll()
        setupBoxes()
    }
    
    private func clearAnimator() {
        behavior.removeBoundary("leftwall")
        behavior.removeBoundary("topwall")
        behavior.removeBoundary("rightwall")
        behavior.removeBoundary("bottomwall")
        behavior.removeBoundary("paddle")
        paddleGravity.removeItem(paddle)
        paddleCollider.removeItem(paddle)
        behavior.removeItemFromBehaviors(ball)
        animator.removeAllBehaviors()
    }
    
    private func prepareUI() {
        ball.removeFromSuperview()
        paddle.removeFromSuperview()
        gameView.addSubview(ball)
        gameView.addSubview(paddle)
        placePaddle()
        updateBlockPositions()
        placeBall()
        ballCenter = ball.center
    }
    
    private func setupAnimator() {
        animator.updateItemUsingCurrentState(gameView)
        animator.addBehavior(behavior)
        animator.addBehavior(paddleGravity)
        animator.addBehavior(paddleCollider)
        paddleCollider.translatesReferenceBoundsIntoBoundary = true
  //      paddleCollider.addItem(paddle)
        behavior.addBallToBehaviors(ball)
        behavior.addBoundary("paddle", path: createBoundary(paddle))
        behavior.addBoundary("leftwall", start: gameView.frame.origin, end: CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        behavior.addBoundary("topwall", start: gameView.frame.origin, end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        behavior.addBoundary("rightwall", start: CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y), end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
        behavior.addBoundary("bottomwall", start: CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY), end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
    }
    
    private func createBoundary(view: UIView) -> (UIBezierPath) {
        let path = UIBezierPath(rect: CGRect(origin: view.frame.origin, size: view.frame.size))
        return path
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        let center = NSNotificationCenter.defaultCenter()
        let notificationQueue = NSOperationQueue.mainQueue()
        let receiver = behavior
        center.addObserverForName(BallNotification.outNotification, object: receiver, queue: notificationQueue) { (NSNotification) -> Void in
            self.showGameOver(.Lose)
        }
        center.addObserverForName(BallNotification.newCenter, object: receiver, queue: notificationQueue) { (notification) -> Void in
            if let center = notification.userInfo?[BallNotification.key] as? NSValue {
                self.ballCenter = center.CGPointValue()
            }
        }
        behavior.bounceCollider.collisionDelegate = self
        reset()
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
     //   paddleGravity.addItem(paddle)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
        if didUpdateAnything == true {
            reset()
            clearAnimator()
            prepareUI()
            setupAnimator()
            didUpdateAnything = false
        } else {
            clearAnimator()
            prepareUI()
            setupAnimator()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
    }
    
    override func viewDidAppear(animated: Bool) {
       super.viewDidAppear(animated)
        print("viewDidAppear")

//        paddleGravity.addItem(paddle)
        
//        let motionManager = AppDelegate.Motion.Manager
//        if motionManager.accelerometerAvailable {
//            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
//                if let accelData = data {
//                    self.paddleGravity.gravityDirection = CGVector(dx: accelData.acceleration.x, dy: -accelData.acceleration.y)
//                }
//            })
//        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        animator.removeAllBehaviors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }
    
}