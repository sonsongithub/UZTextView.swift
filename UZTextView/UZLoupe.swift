//
//  UZLoupe.swift
//  UZTextView
//
//  Created by sonson on 2017/03/28.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit

internal class UZLoupe: UIView {
    static let radius = CGFloat(40)
    var image = UIImage()
    var textView: UZTextView?
    
    internal init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UZLoupe.radius * 2, height: UZLoupe.radius * 2))
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var center: CGPoint {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let textView = textView else { return }
        let textViewBackgroundColor = textView.backgroundColor ?? UIColor.white
        
        textViewBackgroundColor.setFill()
        context.addArc(center: CGPoint(x: UZLoupe.radius, y: UZLoupe.radius), radius: UZLoupe.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        context.closePath()
        context.drawPath(using: .fill)
        
        context.saveGState()
        context.addArc(center: CGPoint(x: UZLoupe.radius, y: UZLoupe.radius), radius: UZLoupe.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        context.closePath()
        context.clip()
        image.draw(at: .zero)
        context.restoreGState()
        
        tintColor.withAlphaComponent(1).setStroke()
        context.saveGState()
        context.setLineWidth(2)
        context.addArc(center: CGPoint(x: UZLoupe.radius, y: UZLoupe.radius), radius: UZLoupe.radius - 1, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        context.closePath()
        context.drawPath(using: .stroke)
        context.restoreGState()
    }
    
    private func keyWindow(from view: UIView) -> UIView {
        guard let parent = view.superview else { return view }
        if parent.isKind(of: UIWindow.self) {
            return view
        }
        return keyWindow(from: parent)
    }
    
    internal func move(to point: CGPoint) {
        guard let textView = textView else { return }
        
//        guard let targetView = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
        let targetView = keyWindow(from: textView)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: UZLoupe.radius * 2, height: UZLoupe.radius * 2), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var nextCenter = textView.convert(point, to: targetView)
        
        context.translateBy(x: -point.x + UZLoupe.radius, y: -point.y + UZLoupe.radius)
        
        nextCenter.y -= UZLoupe.radius
    
        isHidden = true
        textView.layer.render(in: context)
        isHidden = false
        
        image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        setNeedsDisplay()
        targetView.addSubview(self)
        self.center = nextCenter
    }
    
}
