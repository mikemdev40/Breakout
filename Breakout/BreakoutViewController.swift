//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Michael Miller on 11/4/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//


//CODE WRITTEN TO WORK ON BOTH PROTRAIT AND LANDSCAPE, BUT IN THIS VERSION IN WHICH THE CORE MOTION IS BEING USED TO CONTROL THE PADDLE, landscape was turned off in the settings panel to prevent the tilting of the phone when controlling the paddle to convert to a rotation accidentally

import UIKit

protocol GameViewDataSource {
    var numberOfRowsData: Int { get }
    var blocksPerRowData: Int { get }
    var challengeMode: Bool { get }
}

class BreakoutViewController: UIViewController, UICollisionBehaviorDelegate {
    
    // MARK: Constants
    private struct Constants {
        static let defaultRows = 4
        static let defaultBlocks = 5
        static let heightToWidthRatio: CGFloat = 2/3
        static let topIndentBeforeFirstRow: CGFloat = 20
        static let topPortionOfScreenForBlocks: CGFloat = 0.5
        static let paddleHeight: CGFloat = 15
        static let ballRadius: CGFloat = 5
        static let circleToBallRatio: CGFloat = 1
        static let paddleFromBottomOffset: CGFloat = 0
        static let paddleGravityMagnitude: CGFloat = 1
        static let fractionOfWidthThatEqualsPaddle: CGFloat = 0.2
        static let defaultPaddleWidth: CGFloat = 75
    }
    
    private enum gameOver {
        case Win
        case Lose
    }
    
    // MARK: Variables
    
    var testModeWithBottomBoundary = true
    
    var verticalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    
    var paddleWidth: CGFloat {
        if let gameWidth = gameView?.frame.width {
            return gameWidth * Constants.fractionOfWidthThatEqualsPaddle
        } else {
            return Constants.defaultPaddleWidth
        }
    }

    var blocksPerRow: CGFloat {
        if let blocks = dataSource?.blocksPerRowData {
          //  print("datasource blocks")
            return CGFloat(blocks)
        } else {
            if let blocks = AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.blocksPerRowKey) as? Float {
          //      print("UserSettings blocks")
                return CGFloat(blocks)
            } else {
          //      print("default blocks")
                return CGFloat(Constants.defaultBlocks)
            }
        }
    }
    
    var numberOfRows: CGFloat {
        if let rows = dataSource?.numberOfRowsData {
          //  print("dataSource Rows")
            return CGFloat(rows)
        } else {
            if let rows = AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.numRowsKey) as? Float {
          //      print("UserSettings Rows")
                return CGFloat(rows)
            } else {
          //      print("default rows")
                return CGFloat(Constants.defaultRows)
            }
        }
    }
    
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
    
    let paddleGravity = UIGravityBehavior()
    let paddleCollider = UICollisionBehavior()
    var behavior = BreakoutBehavior()
    var collisionDidEnd = true
    
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
        /*  CODE BELOW WORKED!  commented out because it doesn't work in conjunction with using core motion to place the paddle
        
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
        */
    }
    
    func didTap(gesture: UIGestureRecognizer) {
        behavior.pushBall(ball)
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if collisionDidEnd {  //required to prevent the "double hit" that was sometimes detected, which turned the block yellow AND removed the block in a single hit; this work around works because a "double hit" registers TWO calls to this function BEFORE the first hit registers the "endedContactForItem" function below; IMPORTANT!! the endedContactForItem function is called for the yellow -> removed situation AFTER The 0.5 second animation, so it was necessary to place a "collisionDidEnd = true" statement in both places below (within the "else" and also within the endedContactForItem function)
            
            if let collidedBoundary = identifier as? String {
                if let collidedInt = Int(collidedBoundary) {
                    collisionDidEnd = false
                    let collided = "\(collidedInt)"
                    if let block = blocks[collided] {
                        if blocksChallengeSetting[collided] == true {
                            //   print(collided)
                            block.backgroundColor = UIColor.yellowColor()
                            blocksChallengeSetting[collided] = false
                        } else {
                            //    print("else! \(collided)")
                            behavior.removeBoundaryWithIdentifier(collided)
                            behavior.removeItem(block)
                            blocks[collided] = nil
                            collisionDidEnd = true
                            UIView.animateWithDuration(0.5, animations: { () -> Void in
                                block.backgroundColor = UIColor.blueColor()
                                block.alpha = 0
                                },
                                completion: { [unowned self] (Bool) -> Void in
                                    block.removeFromSuperview()
                                    if self.blocks.count == 0 {
                                        self.showGameOver(.Win)
                                        if self.testModeWithBottomBoundary {
                                            self.behavior.removeBoundary("bottomwall")
                                        }
                                    }
                                })
                        }
                    }
                }
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        collisionDidEnd = true
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
      //  ball.backgroundColor = UIColor.blackColor()
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
            //if dataSource?.challengeMode == true {
            if let cmode = AppDelegate.UserSettings.settings.objectForKey(AppDelegate.UserSettings.challengeModeKey) as? Bool {
                if cmode {
                    blocksChallengeSetting["\(index)"] = true
                 //   print("settings: challenge mode ON")
                } else {
                    blocksChallengeSetting["\(index)"] = false
                 //   print("settings: challenge mode OFF")
                }
            } else {
                blocksChallengeSetting["\(index)"] = false
              //  print("default: off")
            }
            index++
        }
    }
    
    private func showGameOver(end: gameOver) {
        if presentedViewController == nil {
            var alert: UIAlertController
            switch end {
            case .Lose:
                alert = UIAlertController(title: "Game Over", message: "Try again?", preferredStyle: .Alert)
            case .Win:
                alert = UIAlertController(title: "YOU WIN!", message: "Play again?", preferredStyle: .Alert)
            }
            alert.addAction(UIAlertAction(title: "Reset", style: .Default, handler: { (UIAlertAction) -> Void in
                self.reset()
                self.clearAnimator()
                self.prepareUI()
                self.setupAnimator()
            }))
            alert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (UIAlertAction) -> Void in
                self.clearAnimator()
                self.prepareUI()
                self.setupAnimator()
            }))
            alert.addAction(UIAlertAction(title: "End", style: .Default, handler: nil))

            presentViewController(alert, animated: true, completion: nil)
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
        if testModeWithBottomBoundary {
            behavior.removeBoundary("bottomwall")
        }
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
        paddleGravity.magnitude = Constants.paddleGravityMagnitude
        animator.addBehavior(paddleCollider)
        paddleCollider.translatesReferenceBoundsIntoBoundary = true
   //     paddleCollider.addItem(paddle)
        behavior.addBallToBehaviors(ball)
        behavior.addBoundary("paddle", path: createBoundary(paddle))
        behavior.addBoundary("leftwall", start: gameView.frame.origin, end: CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY))
        behavior.addBoundary("topwall", start: gameView.frame.origin, end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y))
        behavior.addBoundary("rightwall", start: CGPoint(x: gameView.frame.maxX, y: gameView.frame.origin.y), end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
        if testModeWithBottomBoundary {
            behavior.addBoundary("bottomwall", start: CGPoint(x: gameView.frame.origin.x, y: gameView.frame.maxY), end: CGPoint(x: gameView.frame.maxX, y: gameView.frame.maxY))
        }
    }
    
    private func createBoundary(view: UIView) -> (UIBezierPath) {
        let path = UIBezierPath(rect: CGRect(origin: view.frame.origin, size: view.frame.size))
        return path
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("breakout did load")
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
//        paddleGravity.magnitude = Constants.paddleGravityMagnitude
//        paddleGravity.addItem(paddle)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.Motion.Manager.stopAccelerometerUpdates()
        animator.removeAllBehaviors()
    }
    
    override func viewDidAppear(animated: Bool) {
       super.viewDidAppear(animated)

//        paddleGravity.addItem(paddle)
//        paddleGravity.magnitude = Constants.paddleGravityMagnitude
        
        let motionManager = AppDelegate.Motion.Manager
        if !motionManager.deviceMotionActive {
            if motionManager.deviceMotionAvailable {
                 motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { [unowned self] (data, error) -> Void in
                    if let motionData = data {
                        let roll = min(max(motionData.attitude.roll, -0.3), 0.3)
                        let mapping = (roll + 0.3)/0.6
                        self.paddle.frame.origin.x = CGFloat(mapping) * (self.gameView.frame.width - self.paddle.frame.width)
                        self.behavior.removeBoundary("paddle")
                        self.behavior.addBoundary("paddle", path: self.createBoundary(self.paddle))
                    }
                })
            }
        }
        
        /*  CODE BELOW WORKS!  but works INSTEAD of code above; code above is smoother and more responsive; if code below is uncommented, be sure to uncomment the paddleGravity statements above
        
        if !motionManager.accelerometerActive {
            if motionManager.accelerometerAvailable {
                motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in
                    if let accelData = data {
                        self.paddleGravity.gravityDirection = CGVector(dx: accelData.acceleration.x, dy: 0)
                        //self.paddleGravity.gravityDirection = CGVector(dx: accelData.acceleration.x, dy: -accelData.acceleration.y)
                    }
                })
            }
        }
        
        paddleGravity.action = { [unowned self] in
            self.behavior.removeBoundary("paddle")
            self.behavior.addBoundary("paddle", path: self.createBoundary(self.paddle))
        }
        */
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MEMORY WARNING")
    }
    
}