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
    var magnitude: CGFloat = 0.1
    
//    func randomAngle() -> CGFloat {
//        
//    }
    
    func addBoundary(name: String, path: UIBezierPath) {
        bounceCollider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBoundary(name: String) {
        bounceCollider.removeBoundaryWithIdentifier(name)
    }
    
    func addBallToBehaviors(view: UIView) {
        bounceCollider.addItem(view)
 //       gravity.addItem(view)
        push = UIPushBehavior(items: [view], mode: .Instantaneous)
        push.angle = CGFloat(-M_PI_4)
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
        bounceCollider.translatesReferenceBoundsIntoBoundary = true
    }
}
