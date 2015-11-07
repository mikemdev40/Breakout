//
//  GameView.swift
//  Breakout
//
//  Created by Michael Miller on 11/7/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class GameView: UIView {

    override func drawRect(rect: CGRect) {
        let outerBoundary = UIBezierPath()
        outerBoundary.moveToPoint(CGPoint(x: frame.origin.x, y: frame.maxY))
        outerBoundary.addLineToPoint(CGPointZero)
        outerBoundary.addLineToPoint(CGPoint(x: frame.maxX, y: frame.origin.y))
        outerBoundary.addLineToPoint(CGPoint(x: frame.maxX, y: frame.maxY))
        outerBoundary.stroke()
    }

}
