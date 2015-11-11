//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Michael Miller on 11/7/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

struct BallNotification {
    static let outNotification = "ball is out of bounds"
    static let newCenter = "new ball center"
    static let key = "center key"
}

class BreakoutBehavior: UIDynamicBehavior {
    
    var bounceCollider = UICollisionBehavior()
    var gravity = UIGravityBehavior()
    var push = UIPushBehavior()
    var magnitude: CGFloat = 0.01
    var angle: CGFloat {
        return randomAngle()
    }
    
    var ballCenter = CGPoint()
    var center = NSNotificationCenter()
    
    lazy var bounciness: UIDynamicItemBehavior = {
        let lazyBounciness = UIDynamicItemBehavior()
        lazyBounciness.allowsRotation = false
        lazyBounciness.elasticity = 1
        lazyBounciness.resistance = 0
        lazyBounciness.friction = 0
        return lazyBounciness
    }()
    
    func randomAngle() -> CGFloat {
        var random = Double(arc4random_uniform(UInt32(1000)))/8000
        if arc4random_uniform(UInt32(2)) == 1 {
            random = (random + 3/16) * M_PI
        } else {
            random = (random + 11/16) * M_PI
        }
        return CGFloat(random)
    }
    
    func addBoundary(name: String, path: UIBezierPath) {
        bounceCollider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBoundary(name: String, start: CGPoint, end: CGPoint) {
        bounceCollider.addBoundaryWithIdentifier(name, fromPoint: start, toPoint: end)
    }
    
    func removeBoundary(name: String) {
        bounceCollider.removeBoundaryWithIdentifier(name)
    }
    
    func pushBall(ball: UIView) {
        push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        push.angle = angle
        push.magnitude = magnitude
        push.action = { [unowned self] in
            self.removeChildBehavior(self.push)
        }
        addChildBehavior(push)
    }
    
    func addBallToBehaviors(view: UIView) {
        bounciness.action = {
            self.ballCenter = view.center
        }
        bounciness.addItem(view)
        bounceCollider.addItem(view)
        bounceCollider.action = nil
        bounceCollider.action = { [unowned self] in
            let ball = view
            let centerNotification = NSNotification(name: BallNotification.newCenter, object: self, userInfo: [BallNotification.key: NSValue(CGPoint: self.ballCenter)])
            self.center.postNotification(centerNotification)
            if let gameView = self.dynamicAnimator?.referenceView {
                if ball.frame.origin.y > gameView.frame.maxY + 5 {
                    //  print("out of bounds")
                    ball.removeFromSuperview()
                    self.dynamicAnimator?.removeAllBehaviors()
                    let outNotifcation = NSNotification(name: BallNotification.outNotification, object: self)
                    self.center.postNotification(outNotifcation)
                }
            }
        }
        pushBall(view)
    }
    
    func removeItemFromBehaviors(view: UIView) {
        bounceCollider.removeItem(view)
        bounciness.removeItem(view)
        //       gravity.removeItem(view)
        push.removeItem(view)
    }
    
    override init() {
        super.init()
        addChildBehavior(bounceCollider)
        addChildBehavior(gravity)
        addChildBehavior(bounciness)
        center = NSNotificationCenter.defaultCenter()
        //     bounceCollider.translatesReferenceBoundsIntoBoundary = true
    }
}
