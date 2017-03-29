//
//  UZLoupe.swift
//  UZTextView
//
//  Created by sonson on 2017/03/28.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit

internal class UZLoupe: UIView, CAAnimationDelegate {
    static let radius = CGFloat(60)
    var image = UIImage()
    var textView: UZTextView?
    
    internal init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UZLoupe.radius * 2, height: UZLoupe.radius * 2))
        backgroundColor = UIColor.clear
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isHidden = true
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

    private func show() {
        guard isHidden == true else { return }
        isHidden = false
        
        let alphaAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = [0, 0.97, 1]
            animation.keyTimes = [0, 0.7, 1]
            return animation
        }()
        let scaleAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [0, 1]
            animation.keyTimes = [0, 1]
            return animation
        }()
        let tranlateAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            animation.values = [(self.frame.size.height * CGFloat(0.5)) as NSNumber, 0]
            animation.keyTimes = [0, 1]
            return animation
        }()
        
        let group = CAAnimationGroup()
        group.animations = [alphaAnimation, scaleAnimation, tranlateAnimation]
        group.duration = 0.2
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.delegate = self
        
        group.setValue("show", forKey: "name")
        self.layer.add(group, forKey: "show")
    }
    
    private func hide() {
        let alphaAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = [1, 0.97, 0]
            animation.keyTimes = [0, 0.7, 1]
            return animation
        }()
        let scaleAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [1, 0]
            animation.keyTimes = [0, 1]
            return animation
        }()
        let tranlateAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            animation.values = [0, (self.frame.size.height * CGFloat(0.5)) as NSNumber]
            animation.keyTimes = [0, 1]
            return animation
        }()
        
        let group = CAAnimationGroup()
        group.animations = [alphaAnimation, scaleAnimation, tranlateAnimation]
        group.duration = 0.2
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.delegate = self
        
        group.setValue("hide", forKey: "name")
        self.layer.add(group, forKey: "hide")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let name = anim.value(forKey: "name") as? String else { return }
        if name == "show" {
        } else if name == "hide" {
            isHidden = true
        }
    }
    
    internal func setVisible(visible: Bool) {
        if visible {
            show()
        } else {
            hide()
        }
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
    
        let prev = isHidden
        isHidden = true
        textView.layer.render(in: context)
        isHidden = prev
        
        image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        setNeedsDisplay()
        targetView.addSubview(self)
        self.center = nextCenter
    }
    
}
