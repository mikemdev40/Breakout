//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Michael Miller on 11/7/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {

    var bounceCollider = UICollisionBehavior()
    var gravity = UIGravityBehavior()
    var push = UIPushBehavior()
    var magnitude: CGFloat = 0.01
    var angle: CGFloat {
        return randomAngle()
    }
    
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
        bounceCollider.addItem(view)
        bounceCollider.action = nil
        bounceCollider.action = { [unowned self] in
            let ball = view
            if let gameView = self.dynamicAnimator?.referenceView {
                if ball.frame.origin.y > gameView.frame.maxY + 5 {
                  //  print("out of bounds")
                    ball.removeFromSuperview()
                    self.dynamicAnimator?.removeAllBehaviors()
                    let center = NSNotificationCenter.defaultCenter()
                    let notifcation = NSNotification(name: BallNotification.outNotification, object: self)
                    center.postNotification(notifcation)
                }
            }
        }
        pushBall(view)
    }
    
    func removeItemFromBehaviors(view: UIView) {
        bounceCollider.removeItem(view)
 //       gravity.removeItem(view)
        push.removeItem(view)
    }
    
    override init() {
        super.init()
        addChildBehavior(bounceCollider)
        addChildBehavior(gravity)
   //     bounceCollider.translatesReferenceBoundsIntoBoundary = true
    }
}
