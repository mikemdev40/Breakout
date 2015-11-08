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
//    lazy var push: UIPushBehavior = {
//        var lazyPush = UIPushBehavior()
//        if let animator = self.dynamicAnimator?.referenceView {
//            lazyPush = UIPushBehavior(items: [animator], mode: .Instantaneous)
//            print("push added")
//        }
//        return lazyPush
//    }()
    
    lazy var bounciness: UIDynamicItemBehavior = {
        let lazyBounciness = UIDynamicItemBehavior()
        lazyBounciness.allowsRotation = false
        lazyBounciness.elasticity = 1
        lazyBounciness.resistance = 0
        lazyBounciness.friction = 0
        return lazyBounciness
    }()
    
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
        bounciness.addItem(view)
        push = UIPushBehavior(items: [view], mode: .Instantaneous)
        push.angle = CGFloat(-M_PI_4)
        push.magnitude = 0.05
        push.action = { [unowned self] in
            self.removeChildBehavior(self.push)
            print("push removed")
        }
        addChildBehavior(push)
    }
    
    func removeItemFromBehaviors(view: UIView) {
        bounceCollider.removeItem(view)
        gravity.removeItem(view)
        push.removeItem(view)
    }
    
    override init() {
        super.init()
        addChildBehavior(bounceCollider)
        addChildBehavior(gravity)
        addChildBehavior(bounciness)
        bounceCollider.translatesReferenceBoundsIntoBoundary = true
    }
}
