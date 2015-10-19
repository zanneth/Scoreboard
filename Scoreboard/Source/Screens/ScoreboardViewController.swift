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
    private var _transientMessageLabel:  VectorLabel = VectorLabel(text: "", size: 36.0)
    private var _highscoresViews:        [ScoreView] = []
    private var _xionDataSource:         XionDataSource!
    private var _currentlyPollingGame:   Game?
    
    static private let kScreenPadding:          CGFloat = 50.0
    static private let kScoresListRatio:        CGFloat = 1.0/2.3
    static private let kScoreViewsMarginY:      CGFloat = 30.0
    static private let kScoreViewsToShowCount:  UInt    = 10
    
    init(gameName: String)
    {
        self.gameName = gameName
        
        let xionBaseURL = NSURL(string: "http://REPLACE_ME") as NSURL!
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
        let theme = Theme.tempestTheme()
        
        _xionTitleLabel.textAttributes = [NSForegroundColorAttributeName : theme.foregroundGreenColor]
        self.view.addSubview(_xionTitleLabel)
        
        _highscoresTitleLabel.textAttributes = [NSForegroundColorAttributeName : theme.foregroundRedColor]
        self.view.addSubview(_highscoresTitleLabel)
        
        _copyrightLabel.textAttributes = [NSForegroundColorAttributeName : theme.foregroundBlueColor]
        self.view.addSubview(_copyrightLabel)
        
        _transientMessageLabel.textAttributes = [NSForegroundColorAttributeName : theme.foregroundRedColor]
        _transientMessageLabel.text = "LOADING..."
        self.view.addSubview(_transientMessageLabel)
        
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
        
        // layout title label
        let xionTitleLabelSize = _xionTitleLabel.sizeThatFits(CGSizeZero)
        let xionTitleLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - xionTitleLabelSize.width / 2.0),
            y: ScoreboardViewController.kScreenPadding,
            width: xionTitleLabelSize.width,
            height: xionTitleLabelSize.height
        )
        _xionTitleLabel.frame = xionTitleLabelFrame
        
        // layout "HIGH SCORES" label
        let highscoresLabelSize = _highscoresTitleLabel.sizeThatFits(CGSizeZero)
        let highscoresLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - highscoresLabelSize.width / 2.0),
            y: rint(bounds.size.height / 8.0),
            width: highscoresLabelSize.width,
            height: highscoresLabelSize.height
        )
        _highscoresTitleLabel.frame = highscoresLabelFrame
        
        // layout copyright
        let copyrightLabelSize = _copyrightLabel.sizeThatFits(CGSizeZero)
        let copyrightLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - copyrightLabelSize.width / 2.0),
            y: rint(bounds.size.height - copyrightLabelSize.height - ScoreboardViewController.kScreenPadding),
            width: copyrightLabelSize.width,
            height: copyrightLabelSize.height
        )
        _copyrightLabel.frame = copyrightLabelFrame
        
        // layout score views
        // compute score views vertical space
        let scoreViewsWidth = bounds.size.width * ScoreboardViewController.kScoresListRatio
        let scoreViewsMaxBounds = CGRect(x: 0.0, y: 0.0, width: scoreViewsWidth, height: CGFloat.max)
        var scoreViewsCompositeHeight: CGFloat = 0.0
        for highscoreView in _highscoresViews {
            let highscoreViewSize = highscoreView.sizeThatFits(scoreViewsMaxBounds.size)
            scoreViewsCompositeHeight += highscoreViewSize.height + ScoreboardViewController.kScoreViewsMarginY
        }
        
        let scoreViewsBoundsOriginY = CGRectGetMaxY(_highscoresTitleLabel.frame)
        let scoreViewsBoundsHeight = CGRectGetMinY(_copyrightLabel.frame) - scoreViewsBoundsOriginY
        let scoreViewsBounds = CGRect(
            x: rint(bounds.size.width / 2.0 - scoreViewsWidth / 2.0),
            y: rint(scoreViewsBoundsOriginY + (scoreViewsBoundsHeight / 2.0 - scoreViewsCompositeHeight / 2.0)),
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
        
        // layout transient message view
        let messageLabelSize = _transientMessageLabel.sizeThatFits(CGSizeZero)
        let messageLabelFrame = CGRect(
            x: rint(bounds.size.width / 2.0 - messageLabelSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - messageLabelSize.height / 2.0),
            width: messageLabelSize.width,
            height: messageLabelSize.height
        )
        _transientMessageLabel.frame = messageLabelFrame
    }
    
    // MARK: Internal
    
    internal func _updateScoreboard()
    {
        _xionDataSource.fetchGames { (games: [Game], error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var scoreboardGame: Game? = nil
                
                if (error == nil) {
                    for game: Game in games {
                        if (game.name == self.gameName) {
                            scoreboardGame = game
                            break
                        }
                    }
                }
                
                if scoreboardGame != nil {
                    self._publishScoreboardUI(scoreboardGame!)
                    self._startPollingGame(scoreboardGame!)
                } else {
                    print("Error loading games: \(error)")
                    self._showError()
                }
            })
        }
    }
    
    internal func _startPollingGame(game: Game)
    {
        if _currentlyPollingGame != nil {
            _stopPollingAnyGames()
        }
        
        _currentlyPollingGame = game
        
        _xionDataSource.pollForGameUpdate(game, completion: { (updatedGame: Game?, error: NSError?) -> Void in
            self._currentlyPollingGame = nil
            
            if updatedGame != nil {
                self._publishScoreboardUI(updatedGame!)
                self._startPollingGame(updatedGame!)
            } else {
                print("Error loading game update: \(error)")
                self._updateScoreboard() // try an update
            }
        })
    }
    
    internal func _stopPollingAnyGames()
    {
        if _currentlyPollingGame != nil {
            _xionDataSource.cancelGameUpdatePoll(_currentlyPollingGame!)
        }
        _currentlyPollingGame = nil
    }
    
    internal func _clearHighscoresViews()
    {
        for existingView: ScoreView in self._highscoresViews {
            existingView.removeFromSuperview()
        }
        self._highscoresViews.removeAll()
    }
    
    internal func _publishScoreboardUI(scoreboardGame: Game)
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var highscoresViews: [ScoreView] = []
            var ordinal: UInt = 1
            
            let scores: [Score] = scoreboardGame.scores
            let sortedScores: [Score] = scores.sort({ (score1: Score, score2: Score) -> Bool in
                return score1.scoreValue >= score2.scoreValue
            })
            
            for score: Score in sortedScores {
                let scoreView = ScoreView(score: score, ordinal: ordinal)
                highscoresViews.append(scoreView)
                
                self.view.addSubview(scoreView)
                ++ordinal
                
                if ordinal - 1 >= ScoreboardViewController.kScoreViewsToShowCount {
                    break
                }
            }
        
            self._clearHighscoresViews()
            self._highscoresViews = highscoresViews
            self._transientMessageLabel.hidden = true
            self.view.setNeedsLayout()
        })
    }
    
    internal func _showError()
    {
        self._clearHighscoresViews()
        self._transientMessageLabel.text = "ERROR LOADING SCORES"
        self._transientMessageLabel.hidden = false
        self.view.setNeedsLayout()
    }
}
