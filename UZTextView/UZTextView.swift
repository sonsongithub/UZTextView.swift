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

extension CFString {
    var fullRange: CFRange {
        let length = CFStringGetLength(self)
        return CFRange(location: 0, length: length)
    }
}

extension String {
    var fullRange: CFRange {
        return CFRange(location: 0, length: self.utf16.count)
    }
}

extension CFRange {
    static var zero: CFRange {
        return CFRange(location: 0, length: 0)
    }
    
    var arange: CountableRange<Int> {
        return self.location..<(self.location + self.length)
    }
}

extension NSRange {
    var arangeIncludingEndIndex: CountableRange<Int> {
        return self.location..<(self.location + self.length + 1)
    }
    
    var arange: CountableRange<Int> {
        return self.location..<(self.location + self.length)
    }
    
    static var zero: NSRange {
        return NSRange(location: 0, length: 0)
    }
    
    static var notFound: NSRange {
        return NSRange(location: NSNotFound, length: 0)
    }
    
    static func == (lhs: NSRange, rhs: NSRange) -> Bool {
        return lhs.location == rhs.location && lhs.length == rhs.length
    }
    
    static func != (lhs: NSRange, rhs: NSRange) -> Bool {
        return lhs.location != rhs.location || lhs.length != rhs.length
    }
}

extension UITouch {
    fileprivate func location(in view: UIView, margin: UIEdgeInsets) -> CGPoint {
        var point = self.location(in: view)
        point.x -= margin.left
        point.y -= margin.top
        return point
    }
}

extension UIGestureRecognizer {
    fileprivate func location(in view: UIView, margin: UIEdgeInsets) -> CGPoint {
        var point = self.location(in: view)
        point.x -= margin.left
        point.y -= margin.top
        return point
    }
}

private func CTLineGetTypographicBounds_(_ line: CTLine) -> (Double, CGFloat, CGFloat, CGFloat) {
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var leading: CGFloat = 0
    let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
    return (width, ascent, descent, leading)
}

struct LineInfo {
    let line: CTLine
    let origin: CGPoint
    let range: NSRange
    
    func getRect(contentSize: CGSize) -> CGRect {
        let (width, ascent, descent, _) = CTLineGetTypographicBounds_(self.line)
        let lineRectSize = CGSize(width: CGFloat(width), height: ascent + descent)
        let lineRectOrigin = CGPoint(x: origin.x, y: origin.y - descent)
        let lineRectInverted = CGRect(origin: lineRectOrigin, size: lineRectSize)
        return CGRect(origin: CGPoint(x: lineRectOrigin.x, y: contentSize.height - lineRectInverted.maxY), size: lineRectSize)
    }
}

enum UZTextViewError: Error, LocalizedError {
    case canNotGetFrame
}

fileprivate func CTLineGetStringNSRange(_ line: CTLine) -> NSRange {
    let lineCFRange = CTLineGetStringRange(line)
    return NSRange(location: lineCFRange.location, length: lineCFRange.length)
}

fileprivate func CTFrameGetLineInfo(frame: CTFrame) throws -> [LineInfo] {
    guard let lines = CTFrameGetLines(frame) as? [CTLine] else { throw UZTextViewError.canNotGetFrame }
    var lineOrigins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
    guard lines.count == lineOrigins.count else { throw UZTextViewError.canNotGetFrame }
    
    return zip(lines, lineOrigins).map({
        let range = CTLineGetStringNSRange($0.0)
        return LineInfo(line: $0.0, origin: $0.1, range: range)
    })
}

public class UZTextView: UIView {
    var ctframe: CTFrame!
    var ctframeSetter: CTFramesetter!
    var contentSize: CGSize = CGSize.zero
    
    var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    var selectedRange = NSRange.notFound
    var tappedLinkRange = NSRange.notFound
    
    var selectedColor: UIColor = UIColor.blue.withAlphaComponent(0.3)
    var highlightedColor: UIColor = UIColor.yellow.withAlphaComponent(0.3)
    var tappedLinkColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3)
    
    public var attributedString: NSAttributedString = NSAttributedString(string: "") {
        didSet {
            updateLayout()
        }
    }
    
    public var string: String {
        return attributedString.string
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
        setupGestureRecognizer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizer()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
        self.setNeedsDisplay()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self, margin: contentInset)
        
        do {
            let index = try characterIndex(at: point)
            if index != kCFNotFound {
                let string = self.attributedString.string
                let si = string.index(string.startIndex, offsetBy: index + 0)
                let ei = string.index(string.startIndex, offsetBy: index + 1)
                print(string.substring(with: si..<ei))
            }
        } catch {
            print("\(error)")
        }
        updateTappedLinkRange(at: point)
        setNeedsDisplay()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        tappedLinkRange = NSRange.notFound
        setNeedsDisplay()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        tappedLinkRange = NSRange.notFound
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if tappedLinkRange != NSRange.notFound {
            for i in tappedLinkRange.location..<(tappedLinkRange.location + tappedLinkRange.length) {
                var effectiveRange = NSRange.notFound
                let attribute = attributedString.attributes(at: i, effectiveRange: &effectiveRange)
                guard let link = attribute[NSLinkAttributeName] else { continue }
                print(link)
                break
            }
            tappedLinkRange = NSRange.notFound
        }
        setNeedsDisplay()
    }
    
    private func updateTappedLinkRange(at point: CGPoint) {
        do {
            let index = try characterIndex(at: point)
            var effectiveRange = NSRange.notFound
            let attribute = self.attributedString.attributes(at: index, effectiveRange: &effectiveRange)
            guard let _ = attribute[NSLinkAttributeName] else { tappedLinkRange = NSRange.notFound; return }
            tappedLinkRange = effectiveRange
        } catch {
            tappedLinkRange = NSRange.notFound
        }
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
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
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
            
        }
        
        selectedColor.setFill()
        rectangles(with: selectedRange).forEach({
            context.fill($0)
        })
        
        tappedLinkColor.setFill()
        rectangles(with: tappedLinkRange).forEach({
            context.fill($0)
        })
    }
    
    private func drawTextBox(_ context: CGContext) throws {
        try CTFrameGetLineInfo(frame: ctframe).forEach({ (lineInfo) in
            let lineRect = lineInfo.getRect(contentSize: contentSize)
            let indices = lineInfo.range.arangeIncludingEndIndex.map({$0})
            zip(indices, indices.dropFirst()).forEach({
                let leftOffset = CTLineGetOffsetForStringIndex(lineInfo.line, $0.0, nil)
                let rightOffset = CTLineGetOffsetForStringIndex(lineInfo.line, $0.1, nil)
                let r = CGRect(x: lineInfo.origin.x + leftOffset, y: lineRect.minY, width: rightOffset - leftOffset, height: lineRect.size.height)
                context.stroke(r)
            })
        })
    }
    
    func didChangeLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            selectedRange = rangeOfWord(at: gestureRecognizer.location(in: self, margin: contentInset))
            self.setNeedsDisplay()
        case .changed:
            selectedRange = rangeOfWord(at: gestureRecognizer.location(in: self, margin: contentInset))
            self.setNeedsDisplay()
        default:
            do {}
        }
    }
    
    private func rectangles(with range: NSRange) -> [CGRect] {
        guard range.length > 0 else { return [] }
        do {
            return try CTFrameGetLineInfo(frame: ctframe)
            .flatMap({
                let lineRect = $0.getRect(contentSize: contentSize)
                let top = lineRect.minY
                let height = lineRect.size.height
                
                let intersect = NSIntersectionRange($0.range, range)
                
                if intersect.length > 0 {
                    let leftOffset = CTLineGetOffsetForStringIndex($0.line, intersect.location, nil)
                    let rightOffset = CTLineGetOffsetForStringIndex($0.line, NSMaxRange(intersect), nil)
                    return CGRect(x: $0.origin.x + leftOffset, y: top, width: rightOffset - leftOffset, height: height)
                } else {
                    return nil
                }
            })
        } catch {
            return []
        }
    }
    
    func rangeOfWord(at point: CGPoint) -> NSRange {
        do {
            let index = try characterIndex(at: point)
            
            let string = self.attributedString.string as CFString
            let range: CFRange = string.fullRange
            guard let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, string, range, kCFStringTokenizerUnitWordBoundary, nil)
                else { return NSRange.notFound }
            
            var tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, index)
            repeat {
                let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
                
                if range.arange ~= index {
                    return NSRange(location: range.location, length: range.length)
                }
                
                tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
            } while tokenType.rawValue != 0
        } catch {
            return NSRange.notFound
        }
        return NSRange.notFound
    }
  
    private func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UZTextView.didChangeLongPressGesture(_:)))
        gestureRecognizer.minimumPressDuration = 0.5
        self.addGestureRecognizer(gestureRecognizer)
        longPressGestureRecognizer = gestureRecognizer
    }
    
    enum UZTextViewCharacterIndex: Error {
        case notFound
    }
    
    private func characterIndex(at point: CGPoint) throws -> Int {
        enum CharacterIndex: Error {
            case find(index: Int)
        }
        do {
            try CTFrameGetLineInfo(frame: ctframe).forEach({ (lineInfo) in
                let lineRange = lineInfo.range
                let lineRect = lineInfo.getRect(contentSize: contentSize)
                guard lineRect.contains(point) else { return }
                let indices = lineRange.arangeIncludingEndIndex.map({$0})
                try zip(indices, indices.dropFirst()).forEach({
                    let leftOffset = CTLineGetOffsetForStringIndex(lineInfo.line, $0.0, nil)
                    let rightOffset = CTLineGetOffsetForStringIndex(lineInfo.line, $0.1, nil)
                    let r = CGRect(x: lineInfo.origin.x + leftOffset, y: lineRect.minY, width: rightOffset - leftOffset, height: lineRect.size.height)
                    if r.contains(point) {
                        throw CharacterIndex.find(index: $0.0)
                    }
                })
                throw UZTextViewCharacterIndex.notFound
            })
        } catch CharacterIndex.find(let index) {
            return index
        } catch {
            throw UZTextViewCharacterIndex.notFound
        }
        throw UZTextViewCharacterIndex.notFound
    }
}
