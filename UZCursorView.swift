//
//  UZCursorView.swift
//  UZTextView
//
//  Created by sonson on 2017/03/27.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit

internal enum UZCursorViewDirection {
    case up
    case down
}

internal class UZCursorView: UIView {
    let direction: UZCursorViewDirection
    
    init(with aDirection: UZCursorViewDirection) {
        direction = aDirection
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        direction = .down
        super.init(coder: aDecoder)
    }
    
    static var ballRadius = CGFloat(4)
    static var poleWidth = CGFloat(2)
    static var poleMargin = CGFloat(7)
    
    static var horizontalMargin1 = CGFloat(30)
    static var horizontalMargin2 = CGFloat(10)
    static var verticalMargin = CGFloat(20)
    
    private func cursorRenderingInfo() -> (CGPoint, CGRect) {
        switch direction {
        case .up:
            let point = CGPoint(x: UZCursorView.horizontalMargin1 - 1, y: UZCursorView.verticalMargin - UZCursorView.poleMargin)
            let rect = CGRect(x: point.x - UZCursorView.poleWidth / 2, y: point.y, width: UZCursorView.poleWidth, height: UZCursorView.verticalMargin * 2 + UZCursorView.poleMargin)
            return (point, rect)
        case .down:
            let point = CGPoint(x: UZCursorView.horizontalMargin2, y: self.frame.size.height - (UZCursorView.verticalMargin - UZCursorView.poleMargin))
            let rect = CGRect(
                x: point.x - UZCursorView.poleWidth / 2,
                y: point.y - (self.frame.size.height - UZCursorView.verticalMargin * 2 + UZCursorView.poleMargin),
                width: UZCursorView.poleWidth,
                height: self.frame.size.height - UZCursorView.verticalMargin * 2 + UZCursorView.poleMargin
            )
            return (point, rect)
        }
    }

    internal func updateLocation(in rect: CGRect) {
        switch direction {
        case .up:
            frame = CGRect(x: rect.origin.x - UZCursorView.horizontalMargin1,
                           y: rect.origin.y - UZCursorView.verticalMargin,
                           width: UZCursorView.horizontalMargin1 + UZCursorView.horizontalMargin2,
                           height: rect.size.height + UZCursorView.verticalMargin - 10)
        case .down:
            do {}
        }
//        + (CGRect)cursorRectWithEdgeRect:(CGRect)rect cursorDirection:(UZTextViewCursorDirection)direction {
//            if (direction == UZTextViewUpCursor) {
//                return CGRectMake(rect.origin.x - UZ_CURSOR_HORIZONTAL_MARGIN1,
//                                  rect.origin.y - UZ_CURSOR_VERTICAL_MARGIN,
//                                  UZ_CURSOR_HORIZONTAL_MARGIN1 + UZ_CURSOR_HORIZONTAL_MARGIN2,
//                                  rect.size.height + UZ_CURSOR_VERTICAL_MARGIN * 2);
//            }
//            else {
//                return CGRectMake(rect.origin.x - UZ_CURSOR_HORIZONTAL_MARGIN2,
//                                  rect.origin.y - UZ_CURSOR_VERTICAL_MARGIN,
//                                  UZ_CURSOR_HORIZONTAL_MARGIN1 + UZ_CURSOR_HORIZONTAL_MARGIN2,
//                                  rect.size.height + UZ_CURSOR_VERTICAL_MARGIN * 2);
//            }
//        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        UIColor.blue.setStroke()
        context.stroke(rect.insetBy(dx: 1, dy: 1))
        
        let (point, rect) = cursorRenderingInfo()
        
        context.addArc(center: point, radius: UZCursorView.ballRadius, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        context.closePath()
        
        self.tintColor.withAlphaComponent(1).setFill()
        context.fillPath()
        context.fill(rect)
    }
}
