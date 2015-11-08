//
//  GameView.swift
//  Breakout
//
//  Created by Michael Miller on 11/7/15.
//  Copyright © 2015 MikeMiller. All rights reserved.
//

import UIKit

class GameView: UIView {

    var locations = [String: UIBezierPath]()
    
    func placeCircle(name: String, circle: UIBezierPath?) {
        locations[name] = circle
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        for (_, circle) in locations {
            circle.stroke()
        }
    }
}
