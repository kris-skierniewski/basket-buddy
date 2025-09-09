//
//  UILabelExtensions.swift
//  price tracker
//
//  Created by Kris Skierniewski on 14/10/2024.
//

import UIKit
import CoreText

extension UILabel {
    func characterIndex(at point: CGPoint) -> CFIndex {
        // Check if the point is within the label's bounds
        if !bounds.contains(point) {
            return NSNotFound
        }
        
        // Get the text rectangle for the label
        let textRect = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        if !textRect.contains(point) {
            return NSNotFound
        }
        
        // Offset tap coordinates by textRect origin
        let adjustedPoint = CGPoint(x: point.x - textRect.origin.x, y: point.y - textRect.origin.y)
        // Convert tap coordinates to CT coordinates (start at bottom left)
        let ctPoint = CGPoint(x: adjustedPoint.x, y: textRect.size.height - adjustedPoint.y)
        
        // Create a path for the text frame
        let path = CGMutablePath()
        path.addRect(textRect)
        let attributedText = attributedText ?? NSAttributedString(string: "")
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedText.length), path, nil)
        
        let lines = CTFrameGetLines(frame)
        let lineCount = numberOfLines > 0 ? min(numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines)
        if lineCount == 0 {
            return NSNotFound
        }
        
        var idx: CFIndex = NSNotFound
        var lineOrigins = [CGPoint](repeating: .zero, count: lineCount)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: lineCount), &lineOrigins)
        
        for lineIndex in 0..<lineCount {
            let lineOrigin = lineOrigins[lineIndex]
            guard let line = CFArrayGetValueAtIndex(lines, lineIndex)?.load(as: CTLine.self) else {
                       continue // Skip if we can't retrieve a valid line
                   }
            
            // Get bounding information of the line
            var ascent: CGFloat = 0.0
            var descent: CGFloat = 0.0
            var leading: CGFloat = 0.0
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            let yMin = floor(lineOrigin.y - descent)
            let yMax = ceil(lineOrigin.y + ascent)
            
            // Apply penOffset for horizontal alignment
            let flushFactor = UILabel.flushFactorFor(textAlignment: textAlignment)
            let penOffset = CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width)
            var adjustedLineOrigin = lineOrigin
            adjustedLineOrigin.x = penOffset
            
            // Check if the point is within this line vertically
            if ctPoint.y > yMax {
                break
            }
            if ctPoint.y >= yMin {
                // Check if the point is within this line horizontally
                if ctPoint.x >= adjustedLineOrigin.x && ctPoint.x <= adjustedLineOrigin.x + width {
                    // Convert CT coordinates to line-relative coordinates
                    let relativePoint = CGPoint(x: ctPoint.x - adjustedLineOrigin.x, y: ctPoint.y - lineOrigin.y)
                    idx = CTLineGetStringIndexForPosition(line, relativePoint)
                    break
                }
            }
        }
        
        return idx
    }
    
    static func flushFactorFor(textAlignment: NSTextAlignment) -> CGFloat {
        switch textAlignment {
        case .center:
            return 0.5;
        case .right:
            return 1.0
        default:
            return 0
        }
    }
    
}
