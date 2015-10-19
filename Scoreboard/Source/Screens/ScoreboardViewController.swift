//
//  ScoreboardViewController.swift
//  Scoreboard
//
//  Created by Charles Magahern on 9/26/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

import Foundation
import UIKit

class ScoreboardViewController: UIViewController {
    let gameName: String
    
    private var _xionTitleLabel:         VectorLabel = VectorLabel(text: "XION ARCADE", size: 20.0)
    private var _highscoresTitleLabel:   VectorLabel = VectorLabel(text: "HIGH SCORES", size: 42.0)
    private var _copyrightLabel:         VectorLabel = VectorLabel(text: "© MMXV XIONSF.COM", size: 20.0)
    private var _highscoresViews:        [ScoreView] = []
    private var _xionDataSource:         XionDataSource!
    
    static public let kForegroundBlueColor:     UIColor = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)
    static private let kForegroundGreenColor:   UIColor = UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
    static private let kScreenPadding:          CGFloat = 50.0
    static private let kScoresListRatio:        CGFloat = 1.0/2.3
    static private let kScoreViewsMarginY:      CGFloat = 30.0
    static private let kScoreViewsToShowCount:  UInt    = 10
    
    init(gameName: String)
    {
        self.gameName = gameName
        
        let xionBaseURL = NSURL(string: "http://midna.xionsf.com") as NSURL!
        _xionDataSource = XionDataSource(baseURL: xionBaseURL)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.gameName = ""
        super.init(coder: aDecoder)
    }
    
    // MARK: UIView overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        _xionTitleLabel.textAttributes = [NSForegroundColorAttributeName : ScoreboardViewController.kForegroundGreenColor]
        self.view.addSubview(_xionTitleLabel)
        
        _highscoresTitleLabel.textAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]
        self.view.addSubview(_highscoresTitleLabel)
        
        _copyrightLabel.textAttributes = [NSForegroundColorAttributeName : ScoreboardViewController.kForegroundBlueColor]
        self.view.addSubview(_copyrightLabel)
        
        _updateScoreboard()
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        let bounds = self.view.bounds
        
        let xionTitleLabelSize = _xionTitleLabel.sizeThatFits(CGSizeZero)
        let xionTitleLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - xionTitleLabelSize.width / 2.0),
            y: ScoreboardViewController.kScreenPadding,
            width: xionTitleLabelSize.width,
            height: xionTitleLabelSize.height
        )
        _xionTitleLabel.frame = xionTitleLabelFrame
        
        let highscoresLabelSize = _highscoresTitleLabel.sizeThatFits(CGSizeZero)
        let highscoresLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - highscoresLabelSize.width / 2.0),
            y: rint(bounds.size.height / 8.0),
            width: highscoresLabelSize.width,
            height: highscoresLabelSize.height
        )
        _highscoresTitleLabel.frame = highscoresLabelFrame
        
        // compute score views vertical space
        let scoreViewsWidth = bounds.size.width * ScoreboardViewController.kScoresListRatio
        let scoreViewsMaxBounds = CGRect(x: 0.0, y: 0.0, width: scoreViewsWidth, height: CGFloat.max)
        var scoreViewsCompositeHeight: CGFloat = 0.0
        for highscoreView in _highscoresViews {
            let highscoreViewSize = highscoreView.sizeThatFits(scoreViewsMaxBounds.size)
            scoreViewsCompositeHeight += highscoreViewSize.height + ScoreboardViewController.kScoreViewsMarginY
        }
        
        let scoreViewsBounds = CGRect(
            x: rint(bounds.size.width / 2.0 - scoreViewsWidth / 2.0),
            y: rint(bounds.size.height / 2.0 - scoreViewsCompositeHeight / 2.0),
            width: scoreViewsWidth,
            height: scoreViewsCompositeHeight
        )
        
        var curScoreViewsOriginY = scoreViewsBounds.origin.y
        for highscoreView in _highscoresViews {
            let highscoreViewSize = highscoreView.sizeThatFits(scoreViewsBounds.size)
            let highscoreViewFrame = CGRect(
                x: scoreViewsBounds.origin.x,
                y: curScoreViewsOriginY,
                width: highscoreViewSize.width,
                height: highscoreViewSize.height
            )
            
            highscoreView.frame = highscoreViewFrame
            curScoreViewsOriginY += highscoreView.bounds.size.height + ScoreboardViewController.kScoreViewsMarginY
        }
        
        let copyrightLabelSize = _copyrightLabel.sizeThatFits(CGSizeZero)
        let copyrightLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - copyrightLabelSize.width / 2.0),
            y: rint(bounds.size.height - copyrightLabelSize.height - ScoreboardViewController.kScreenPadding),
            width: copyrightLabelSize.width,
            height: copyrightLabelSize.height
        )
        _copyrightLabel.frame = copyrightLabelFrame
    }
    
    // MARK: Internal
    
    internal func _updateScoreboard()
    {
        _xionDataSource.fetchGames { (games: [Game]) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var highscoresViews: [ScoreView] = []
                var scoreboardGame: Game? = nil
                
                for game: Game in games {
                    if (game.name == self.gameName) {
                        scoreboardGame = game
                        break
                    }
                }
                
                if scoreboardGame != nil {
                    let scores: [Score] = scoreboardGame!.scores
                    var ordinal: UInt = 1
                    for score: Score in scores {
                        let scoreView = ScoreView(score: score, ordinal: ordinal)
                        highscoresViews.append(scoreView)
                        
                        self.view.addSubview(scoreView)
                        ++ordinal
                        
                        if ordinal - 1 >= ScoreboardViewController.kScoreViewsToShowCount {
                            break
                        }
                    }
                }
                
                for existingView: ScoreView in self._highscoresViews {
                    existingView.removeFromSuperview()
                }
                
                self._highscoresViews = highscoresViews
                self.viewDidLayoutSubviews()
            })
        }
    }
}
