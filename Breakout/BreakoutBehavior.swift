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
    var paddleWallCollider = UICollisionBehavior()
    var gravity = UIGravityBehavior()
    var push = UIPushBehavior()
    
    func addBoundary(view: UIView) {
        //let path = UIBezierPath(rect: CGRect(origin: view.frame.origin, size: view.frame.size))
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: view.frame.origin.x, y: view.frame.maxY))
        path.addLineToPoint(CGPointZero)
        path.addLineToPoint(CGPoint(x: view.frame.maxX, y: view.frame.origin.y))
        path.addLineToPoint(CGPoint(x: view.frame.maxX, y: view.frame.maxY))
  //      paddleWallCollider.addBoundaryWithIdentifier("wall", forPath: path)
    }
    
    func addBallToBehaviors(view: UIView) {
        bounceCollider.addItem(view)
        gravity.addItem(view)
    }
    
    func addPaddleToBehaviors(view: UIView) {
        bounceCollider.addItem(view)
        paddleWallCollider.addItem(view)
    }
    
    func removeItemFromBehaviors(view: UIView) {
        bounceCollider.removeItem(view)
        gravity.removeItem(view)
        paddleWallCollider.removeItem(view)
        push.removeItem(view)
    }
    
    override init() {
        super.init()
        addChildBehavior(bounceCollider)
        addChildBehavior(gravity)
        addChildBehavior(paddleWallCollider)
        paddleWallCollider.translatesReferenceBoundsIntoBoundary = true
    //    bounceCollider.translatesReferenceBoundsIntoBoundary = true
    }
}
