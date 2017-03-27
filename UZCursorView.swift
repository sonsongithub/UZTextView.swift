//
//  UZCursorView.swift
//  UZTextView
//
//  Created by sonson on 2017/03/27.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit

/**
 Cursor which is showed while user is selecting any string in the view.
 */
internal class UZCursorView: UIView {
    /// Cursor's direction.
    private enum UZCursorViewDirection {
        case up
        case down
    }
    
    /// Cursor's direction.
    private let direction: UZCursorViewDirection
    
    private init(with aDirection: UZCursorViewDirection) {
        direction = aDirection
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        direction = .down
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    /// Static width of this view.
    private static var width = CGFloat(10)
    /// Extended height of pole of the cursor.
    private static var extendHeight = CGFloat(15)
    /// Ratio of the radius to the height of the view.
    private static var radiusRatio = CGFloat(0.3)
    
    /**
     Calculate center of the circle, rectangle of the axis and radius of the circle in the view.
     - parameter rect: CGRect structure which means rectangle of the view.
     - returns: Tuple which contains center of the circle, rectangle of the axis and radius of the circle in the view.
     */
    private func cursorRenderingInfo(_ rect: CGRect) -> (CGPoint, CGRect, CGFloat) {
        let axisLength = rect.size.height - UZCursorView.width
        let radius = UZCursorView.width / 2
        switch direction {
        case .up:
            let poleRect = CGRect(x: rect.midX - 1, y: rect.size.height - axisLength - 1, width: 2, height: axisLength + 1)
            let point = CGPoint(x: rect.midX, y: radius + 1)
            return (point, poleRect, radius)
        case .down:
            let poleRect = CGRect(x: rect.midX - 1, y: 0, width: 2, height: axisLength + 1)
            let point = CGPoint(x: rect.midX, y: self.frame.size.height - radius - 1)
            return (point, poleRect, radius)
        }
    }
    
    // MARK: -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let (point, poleRect, radius) = cursorRenderingInfo(rect)
        context.addArc(center: point, radius: radius - 1, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        context.closePath()
        self.tintColor.withAlphaComponent(1).setFill()
        context.fillPath()
        context.fill(poleRect)
    }
    
    // MARK: -
    
    /// Create left cursor
    internal static func createLeftCursor() -> UZCursorView {
        return UZCursorView(with: .up)
    }
    
    /// Create right cursor
    internal static func createRightCursor() -> UZCursorView {
        return UZCursorView(with: .down)
    }
    
    /**
     Update the frame of the view according to the character's frame rect.
     - parameter charcaterRect: CGRect structure which contains charcter's frame on which a cursor is shown.
     */
    internal func updateLocation(in charcaterRect: CGRect) {
        switch direction {
        case .up:
            var rect = charcaterRect
            rect.origin.x -= UZCursorView.width * 0.5
            rect.origin.y -= UZCursorView.extendHeight
            rect.size.width = UZCursorView.width
            rect.size.height += UZCursorView.extendHeight
            self.frame = rect
        case .down:
            var rect = charcaterRect
            rect.origin.x = rect.origin.x + rect.size.width - UZCursorView.width * 0.5
            rect.size.width = UZCursorView.width
            rect.size.height += UZCursorView.extendHeight
            self.frame = rect
        }
    }
}
