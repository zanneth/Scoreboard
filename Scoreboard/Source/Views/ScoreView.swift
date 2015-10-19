//
//  ScoreView.swift
//  Scoreboard
//
//  Created by Charles Magahern on 10/4/15.
//  Copyright © 2015 zanneth. All rights reserved.
//

import Foundation
import UIKit

class ScoreView: UIView {
    var score: Score {
        get
        {
            return _score
        }
        set
        {
            _score = newValue
            
            let playerName = _score.playerName
            let nameLabelText = playerName.substringToIndex(playerName.startIndex.advancedBy(min(playerName.characters.count, 3))).uppercaseString
            _nameLabel.text = nameLabelText
            _valueLabel.text = "\(_score.scoreValue)"
            
            setNeedsLayout()
        }
    }
    
    var ordinal: UInt {
        get
        {
            return _ordinal
        }
        set
        {
            _ordinal = newValue
            _ordinalLabel.text = "\(_ordinal)."
            setNeedsLayout()
        }
    }
    
    private var _score: Score = Score()
    private var _ordinal: UInt = 0
    
    private var _ordinalLabel: VectorLabel = VectorLabel()
    private var _nameLabel: VectorLabel = VectorLabel()
    private var _valueLabel: VectorLabel = VectorLabel()
    
    private let _textColor = Theme.tempestTheme().foregroundBlueColor
    private let _textSize: CGFloat = 32.0
    
    init(score: Score, ordinal: UInt)
    {
        super.init(frame: CGRectZero)
        
        self.score = score
        self.ordinal = ordinal
        
        _ordinalLabel.textSize = _textSize
        _nameLabel.textSize = _textSize
        _valueLabel.textSize = _textSize
        
        _ordinalLabel.textAttributes = [NSForegroundColorAttributeName : _textColor]
        _nameLabel.textAttributes = [NSForegroundColorAttributeName : _textColor]
        
        let valueLabelStyle = NSMutableParagraphStyle()
        valueLabelStyle.alignment = NSTextAlignment.Right
        _valueLabel.textAttributes = [
            NSForegroundColorAttributeName : _textColor,
            NSParagraphStyleAttributeName : valueLabelStyle
        ]
        
        self.addSubview(_ordinalLabel)
        self.addSubview(_nameLabel)
        self.addSubview(_valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let bounds = self.bounds
        
        let ordinalLabelSize = _ordinalLabel.sizeThatFits(bounds.size)
        let ordinalLabelFrame = CGRect(
            origin: CGPointZero,
            size: ordinalLabelSize
        )
        _ordinalLabel.frame = ordinalLabelFrame
        
        let nameLabelSize = _nameLabel.sizeThatFits(bounds.size)
        let nameLabelFrame = CGRect(
            origin: CGPoint(x: ordinalLabelSize.width + 5.0, y: 0.0),
            size: nameLabelSize
        )
        _nameLabel.frame = nameLabelFrame
        
        let valueLabelSize = _valueLabel.sizeThatFits(bounds.size)
        let valueLabelFrame = CGRect(
            origin: CGPoint(x: bounds.size.width - valueLabelSize.width, y: 0.0),
            size: valueLabelSize
        )
        _valueLabel.frame = valueLabelFrame
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize
    {
        return CGSize(
            width: size.width,
            height: rint(_ordinalLabel.sizeThatFits(size).height)
        )
    }
}
