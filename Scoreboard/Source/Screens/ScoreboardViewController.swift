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
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}
