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
        var random: Double
        if arc4random_uniform(UInt32(2)) == 1 {
            random = (Double(arc4random_uniform(UInt32(1000)))/5000 + 0.3) * M_PI
        } else {
            random = (Double(arc4random_uniform(UInt32(1000)))/5000 + 0.5) * M_PI
        }
        print(random)
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
    
    func addBallToBehaviors(view: UIView) {
        bounceCollider.addItem(view)
 //       gravity.addItem(view)
        push = UIPushBehavior(items: [view], mode: .Instantaneous)
        push.angle = angle
        push.magnitude = magnitude
        push.action = { [unowned self] in
            self.removeChildBehavior(self.push)
        }
        addChildBehavior(push)

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
        randomAngle()
    }
}
