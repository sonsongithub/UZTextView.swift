//
//  UZTextView.swift
//  UZTextView
//
//  Created by sonson on 2017/03/24.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import CoreText

extension NSAttributedString {
    var fullRange: CFRange {
        return CFRange(location: 0, length: self.length)
    }
}

extension CFRange {
    static var zero: CFRange {
        return CFRange(location: 0, length: 0)
    }
}

public class UZTextView: UIView {
    var ctframe: CTFrame?
    var ctframeSetter: CTFramesetter?
    var contentSize: CGSize = CGSize.zero
    
    var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    public var attributedString: NSAttributedString = NSAttributedString(string: "") {
        didSet {
            updateLayout()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateLayout() {
        let horizontalMargin = contentInset.left + contentInset.right
        contentSize = CGSize(width: self.frame.size.width - horizontalMargin, height: CGFloat.greatestFiniteMagnitude)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, attributedString.fullRange, nil, contentSize, nil)
        contentSize = frameSize
        let contentRect = CGRect(origin: CGPoint.zero, size: frameSize)
        let path = CGPath(rect: contentRect, transform: nil)
        ctframe = CTFramesetterCreateFrame(frameSetter, CFRange.zero, path, nil)
        ctframeSetter = frameSetter
        
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let ctframe = ctframe else { return }
        
        context.translateBy(x: contentInset.left, y: contentInset.top)
        context.saveGState()
        context.translateBy(x: 0, y: contentSize.height)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = CGAffineTransform.identity
        CTFrameDraw(ctframe, context)
        context.restoreGState()
    }
}
