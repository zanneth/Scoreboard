//
//  VectorLabel.swift
//  Scoreboard
//
//  Created by Charles Magahern on 10/4/15.
//  Copyright © 2015 zanneth. All rights reserved.
//

import Foundation
import UIKit

class VectorLabel: UIView {
    var text: String {
        get
        {
            return _text
        }
        set
        {
            _text = newValue
            self.setNeedsDisplay()
        }
    }
    
    var textAttributes: [String : AnyObject] {
        get
        {
            return _textAttributes
        }
        set
        {
            _textAttributes = newValue
            self.setNeedsDisplay()
        }
    }
    
    var textSize: CGFloat {
        get
        {
            return _textSize
        }
        set
        {
            _textSize = newValue
            self.setNeedsDisplay()
        }
    }
    
    private let _vectorFont = UIFont(name: "Vector Battle", size: 42.0)
    private var _text: String = ""
    private var _textAttributes: [String : AnyObject] = [String : AnyObject]()
    private var _textSize: CGFloat = 42.0
    
    init(text: String)
    {
        super.init(frame: CGRectZero)
        _text = text
    }
    
    init(text: String, size: CGFloat)
    {
        super.init(frame: CGRectZero)
        _text = text
        _textSize = size
    }
    
    convenience init()
    {
        self.init(text: "")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect)
    {
        let textString: NSString = self.text
        let attribs: [String : AnyObject] = _textAttribs()
        
        /* the vector monitor font is really hard to read (especially on retina).
           this routine draws the string with a couple of aliased versions to make
           it appear more bold */
        textString.drawInRect(rect, withAttributes: attribs)
        textString.drawInRect(CGRectOffset(rect, 0.0, 0.5), withAttributes: attribs)
        textString.drawInRect(CGRectOffset(rect, 0.0, -0.5), withAttributes: attribs)
        textString.drawInRect(CGRectOffset(rect, 0.5, 0.0), withAttributes: attribs)
        textString.drawInRect(CGRectOffset(rect, -0.5, 0.0), withAttributes: attribs)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize
    {
        let textString: NSString = self.text
        let textSize = textString.sizeWithAttributes(_textAttribs())
        return CGSizeMake(textSize.width + 1.0, textSize.height + 1.0)
    }
    
    // MARK: Internal
    
    internal func _textAttribs() -> [String : AnyObject]
    {
        var attributes = self.textAttributes
        attributes[NSFontAttributeName] = _vectorFont?.fontWithSize(self.textSize)
        return attributes
    }
}
