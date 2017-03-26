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
    /// A range of all string as CFRange.
    var fullRange: CFRange {
        return CFRange(location: 0, length: self.length)
    }
}

extension CFString {
    /// A range of all string as CFRange.
    var fullRange: CFRange {
        let length = CFStringGetLength(self)
        return CFRange(location: 0, length: length)
    }
}

extension String {
    /// A range of all string as CFRange.
    var fullRange: CFRange {
        return CFRange(location: 0, length: self.utf16.count)
    }
}

extension CFRange {
    /// A range of all string as CFRange.
    static var zero: CFRange {
        return CFRange(location: 0, length: 0)
    }
    
    /// Range as CountableRange<Int> including an end point.
    var arangeIncludingEndIndex: CountableRange<Int> {
        return self.location..<(self.location + self.length + 1)
    }
    
    /// Range as CountableRange<Int> excluding an end point.
    var arange: CountableRange<Int> {
        return self.location..<(self.location + self.length)
    }
    
}

extension NSRange {
    /// Range as CountableRange<Int> including an end point.
    var arangeIncludingEndIndex: CountableRange<Int> {
        return self.location..<(self.location + self.length + 1)
    }
    
    /// Range as CountableRange<Int> excluding an end point.
    var arange: CountableRange<Int> {
        return self.location..<(self.location + self.length)
    }
    
    /// Range means that it does not found anything.
    static var notFound: NSRange {
        return NSRange(location: NSNotFound, length: 0)
    }
    
    /// Overload
    static func == (lhs: NSRange, rhs: NSRange) -> Bool {
        return lhs.location == rhs.location && lhs.length == rhs.length
    }
    
    /// Overload
    static func != (lhs: NSRange, rhs: NSRange) -> Bool {
        return lhs.location != rhs.location || lhs.length != rhs.length
    }
}

extension UITouch {
    /**
     Returns point with respect to the content insets.
     - parameter view: View on which the touch took place.
     - parameter inset: The distance that the string rendering area is inset from the view.
     - returns: CGPoint structure at which the touch took place with respect to the content insets.
     */
    fileprivate func location(in view: UIView, inset: UIEdgeInsets) -> CGPoint {
        var point = self.location(in: view)
        point.x -= inset.left
        point.y -= inset.top
        return point
    }
}

extension UIGestureRecognizer {
    /**
     Returns point which is offset by margin.
     - parameter view: A UIView object on which the gesture took place.
     - parameter inset: The distance that the string rendering area is inset from the view.
     - returns: CGPoint structure that points a location where UIGestureRecognizer recognizes an event with respect to the content insets.
     */
    fileprivate func location(in view: UIView, inset: UIEdgeInsets) -> CGPoint {
        var point = self.location(in: view)
        point.x -= inset.left
        point.y -= inset.top
        return point
    }
}

/**
 Typographic bounds of a CTLine.
 */
fileprivate struct TypographicBounds {
    let width: CGFloat
    let ascent: CGFloat
    let descent: CGFloat
    let leading: CGFloat
}

/**
 Get typofrahics bounds from CTLine.
 - parameter line: The line from which to obtain the typofrahics bounds.
 - returns: A TypographicBounds structure that contains attributes of specified line.
 */
fileprivate func CTLineGetTypographicBounds(_ line: CTLine) -> TypographicBounds {
    var ascent: CGFloat = 0
    var descent: CGFloat = 0
    var leading: CGFloat = 0
    let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
    return TypographicBounds(width: CGFloat(width), ascent: ascent, descent: descent, leading: leading)
}

/**
 Property of line.
 */
struct LineInfo {
    /// CTLine of a line.
    let line: CTLine
    /// Origin of a line.
    let origin: CGPoint
    /// Index range of a line.
    let range: NSRange
    /**
     Returns the rectangle of a line.
     - parameter contentSize: Size of a string content. It uses in order to compensate Y origin of line.
     - returns: A rectangle of line as CGRect considering Y direction and Y origin.
     */
    func getRect(contentSize: CGSize) -> CGRect {
        let typographicBounds = CTLineGetTypographicBounds(self.line)
        let lineRectSize = CGSize(width: typographicBounds.width, height: typographicBounds.ascent + typographicBounds.descent)
        let lineRectOrigin = CGPoint(x: origin.x, y: origin.y - typographicBounds.descent)
        let lineRectInverted = CGRect(origin: lineRectOrigin, size: lineRectSize)
        return CGRect(origin: CGPoint(x: lineRectOrigin.x, y: contentSize.height - lineRectInverted.maxY), size: lineRectSize)
    }
}

/**
 Gets the range of characters that originally spawned the glyphs in the line.
 - parameter line: The line from which to obtain the string range.
 - returns: A NSRange structure that contains the range over the backing store string that spawned the glyphs, or if the function fails for any reason, an empty range.
 */
fileprivate func CTLineGetStringNSRange(_ line: CTLine) -> NSRange {
    let lineCFRange = CTLineGetStringRange(line)
    return NSRange(location: lineCFRange.location, length: lineCFRange.length)
}

/**
 Returns an array of LineInfo objects in the frame.
 - parameter frame: The frame whose line array is returned.
 - returns: Array object containing the LineInfo objects that have line object, origin and indices, or, if there are no lines in the frame, an array with no elements.
 */
fileprivate func CTFrameGetLineInfo(_ frame: CTFrame) -> [LineInfo] {
    guard let lines = CTFrameGetLines(frame) as? [CTLine] else { return [] }
    var lineOrigins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
    guard lines.count == lineOrigins.count else { return [] }
    
    return zip(lines, lineOrigins).map({
        let range = CTLineGetStringNSRange($0.0)
        return LineInfo(line: $0.0, origin: $0.1, range: range)
    })
}

enum UZTextViewError: Error, LocalizedError {
    case canNotGetFrame
}

public class UZTextView: UIView {
    /// The CTFrame opaque type represents a frame containing multiple lines of text. The frame object is the output resulting from the text-framing process performed by a framesetter object.
    var ctframe: CTFrame!
    /// The CTFramesetter opaque type is used to generate text frames. That is, CTFramesetter is an object factory for CTFrame objects.
    var ctframeSetter: CTFramesetter!
    /// CGSize structure which contains the size of string which will be rendered in the view.
    var contentSize: CGSize = CGSize.zero
    /// The distance that the string rendering area is inset from the view.
    var contentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    /// UIGestureRecognizer which detects long press in order to parse words from the string of the view.
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    /// NSRange structure which contains the range user currently selects text. If no text is selected, this value is set to NSRange.notFound.
    var selectedRange = NSRange.notFound
    /// NSRange structure which contains the range user currently is tapping link object among the text. If no link object is selected, this value is set to NSRange.notFound.
    var tappedLinkRange = NSRange.notFound
    
    var selectedColor: UIColor = UIColor.blue.withAlphaComponent(0.6)
    var highlightedColor: UIColor = UIColor.yellow.withAlphaComponent(0.6)
    var tappedLinkColor: UIColor = UIColor.lightGray.withAlphaComponent(0.6)
    
    /// The styled text displayed by the view
    public var attributedString: NSAttributedString = NSAttributedString(string: "") {
        didSet {
            updateLayout()
        }
    }
    
    /// The text displayed by the label, read only
    public var string: String {
        return attributedString.string
    }
    
    // MARK: -
    
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
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Offset
        context.translateBy(x: contentInset.left, y: contentInset.top)
        
        drawAttributedString(context)
        drawBoundingBoxesOfAllCharacters(context)
        drawBackgroundOfSelectedCharacters(context)
        drawBackgroundOfTappedLinkCharacters(context)
    }
    
    // MARK: -
    
    private func drawAttributedString(_ context: CGContext) {
        context.saveGState()
        context.translateBy(x: 0, y: contentSize.height)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = CGAffineTransform.identity
        CTFrameDraw(ctframe, context)
        context.restoreGState()
    }
    
    private func drawBackgroundOfSelectedCharacters(_ context: CGContext) {
        selectedColor.setFill()
        rectangles(with: selectedRange).forEach({
            context.fill($0)
        })
    }
    
    private func drawBackgroundOfTappedLinkCharacters(_ context: CGContext) {
        tappedLinkColor.setFill()
        rectangles(with: tappedLinkRange).forEach({
            context.fill($0)
        })
    }
    
    private func drawBoundingBoxesOfAllCharacters(_ context: CGContext) {
        CTFrameGetLineInfo(ctframe).forEach({ (lineInfo) in
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
    
    // MARK: -
    
    private func testTappedLinkRange() {
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
    }
    
    // MARK: -
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self, inset: contentInset)
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
        testTappedLinkRange()
        setNeedsDisplay()
    }
    
    // MARK: -
    
    private func updateTappedLinkRange(at point: CGPoint) {
        let index = characterIndex(at: point)
        guard index != NSNotFound else { tappedLinkRange = NSRange.notFound; return }
        var effectiveRange = NSRange.notFound
        let attribute = self.attributedString.attributes(at: index, effectiveRange: &effectiveRange)
        guard let _ = attribute[NSLinkAttributeName] else { tappedLinkRange = NSRange.notFound; return }
        tappedLinkRange = effectiveRange
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
    
    func didChangeLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            selectedRange = rangeOfWord(at: gestureRecognizer.location(in: self, inset: contentInset))
            self.setNeedsDisplay()
        case .changed:
            selectedRange = rangeOfWord(at: gestureRecognizer.location(in: self, inset: contentInset))
            self.setNeedsDisplay()
        default:
            do {}
        }
    }
    
    private func rectangles(with range: NSRange) -> [CGRect] {
        guard range.length > 0 else { return [] }
        return CTFrameGetLineInfo(ctframe)
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
    }
    
    func rangeOfWord(at point: CGPoint) -> NSRange {
        let index = characterIndex(at: point)
        guard index != NSNotFound else { return NSRange.notFound }
        
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
        
        return NSRange.notFound
    }
  
    private func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UZTextView.didChangeLongPressGesture(_:)))
        gestureRecognizer.minimumPressDuration = 0.5
        self.addGestureRecognizer(gestureRecognizer)
        longPressGestureRecognizer = gestureRecognizer
    }
    
    private func characterIndex(at point: CGPoint) -> Int {
        enum CharacterIndex: Error {
            case find(index: Int)
        }
        do {
            try CTFrameGetLineInfo(ctframe).forEach({ (lineInfo) in
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
            })
        } catch CharacterIndex.find(let index) {
            return index
        } catch {
            return NSNotFound
        }
        return NSNotFound
    }
}
