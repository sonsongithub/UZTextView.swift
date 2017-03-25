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
    
    override public var frame: CGRect {
        didSet{
            updateLayout()
        }
    }
    
    override public var bounds: CGRect {
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        let horizontalMargin = contentInset.left + contentInset.right
        contentSize = CGSize(width: self.frame.size.width - horizontalMargin, height: CGFloat.greatestFiniteMagnitude)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, attributedString.fullRange, nil, contentSize, nil)
        contentSize.height = frameSize.height
        let contentRect = CGRect(origin: CGPoint.zero, size: contentSize)
        let path = CGPath(rect: contentRect, transform: nil)
        ctframe = CTFramesetterCreateFrame(frameSetter, CFRange.zero, path, nil)
        ctframeSetter = frameSetter
        
        do {
            let _ = try characterIndex(at: CGPoint(x: 30, y: 30))
        } catch {
            print("\(error)")
        }
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
        
        do {
            try drawTextBox(context)
        } catch {
            print("\(error)")
        }
    }
    
    enum UZTextViewError: Error, LocalizedError {
        case canNotGetFrame
    }
    
    private func CTLineGetStringNSRange(_ line: CTLine) -> NSRange {
        let lineCFRange = CTLineGetStringRange(line)
        return NSRange(location: lineCFRange.location, length: lineCFRange.length)
    }
    
    private func CTLineGetTypographicBounds_(_ line: CTLine) -> (Double, CGFloat, CGFloat, CGFloat) {
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        return (width, ascent, descent, leading)
    }
    
    private func drawTextBox(_ context: CGContext) throws {
        guard let ctframe = ctframe else { throw UZTextViewError.canNotGetFrame }
        guard let lines = CTFrameGetLines(ctframe) as? [CTLine] else { throw UZTextViewError.canNotGetFrame }
        var lineOrigins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(ctframe, attributedString.fullRange, &lineOrigins)
        
        var offset = CGRect.zero// CGFloat(0)
        zip(lines, lineOrigins).forEach({
            let lineRange = CTLineGetStringNSRange($0.0)
            let (width, ascent, descent, leading) = CTLineGetTypographicBounds_($0.0)
            //                print("ascent=\(ascent), descent=\(descent), leading=\(leading) ")
            let lineRectSize = CGSize(width: CGFloat(width), height: ascent + descent)
            let lineRectOrigin = CGPoint(x: $0.1.x, y: contentSize.height - ($0.1.y + ascent))
            var lineRect = CGRect(origin: lineRectOrigin, size: lineRectSize)
            offset = lineRect
            lineRect.origin.y = offset.origin.y + offset.size.height
            context.stroke(lineRect)
            print(lineRect)
        })
    }
    
    private func characterIndex(at point: CGPoint) throws -> CFIndex {
        guard let ctframe = ctframe else { throw UZTextViewError.canNotGetFrame }
        guard let lines = CTFrameGetLines(ctframe) as? [CTLine] else { throw UZTextViewError.canNotGetFrame }
        var lineOrigins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
        CTFrameGetLineOrigins(ctframe, attributedString.fullRange, &lineOrigins)
        
        enum UZTextViewIndex: Error {
            case find(index: Int)
            case notFound
        }
        print("-----------------------------------------")
        var offset = CGFloat(0)
        do {
            try zip(lines, lineOrigins).forEach({
                let lineRange = CTLineGetStringNSRange($0.0)
                let (width, ascent, descent, leading) = CTLineGetTypographicBounds_($0.0)
//                print("ascent=\(ascent), descent=\(descent), leading=\(leading) ")
                offset += (ascent + descent + leading)
                let lineRectSize = CGSize(width: CGFloat(width), height: ascent + descent + leading)
                let lineRectOrigin = CGPoint(x: $0.1.x, y: offset)
                let lineRect = CGRect(origin: lineRectOrigin, size: lineRectSize)
              
                let tapRect = CGRect(origin: point, size: CGSize.zero).insetBy(dx: -10, dy: -10)
                print("\(tapRect)-\(lineRect)")
                guard lineRect.intersects(tapRect) else { return }
                
                let index = CTLineGetStringIndexForPosition($0.0, point)
                
                guard index != kCFNotFound && NSLocationInRange(index, lineRange) else { return }
//                print(index)
//                throw UZTextViewIndex.find(index: index > 1 ? index - 1 : index)
            
            })
        } catch UZTextViewIndex.find(let index) {
            print(index)
        }
        
//        CTFrameGetLineOrigins(<#T##frame: CTFrame##CTFrame#>, <#T##range: CFRange##CFRange#>, <#T##origins: UnsafeMutablePointer<CGPoint>!##UnsafeMutablePointer<CGPoint>!#>)
//        CFArrayRef lines = CTFrameGetLines(_frame);
//        CFIndex lineCount = CFArrayGetCount(lines);
//        CGPoint lineOrigins[lineCount];
//        CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), lineOrigins);
//        
//        CGRect previousLineRect = CGRectZero;
        
        return 0
    }
}
