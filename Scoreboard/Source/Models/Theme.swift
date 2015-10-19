//
//  Theme.swift
//  Scoreboard
//
//  Created by Charles Magahern on 10/18/15.
//  Copyright © 2015 zanneth. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    var foregroundRedColor: UIColor
    var foregroundBlueColor: UIColor
    var foregroundGreenColor: UIColor
    
    init()
    {
        self.foregroundRedColor = UIColor()
        self.foregroundBlueColor = UIColor()
        self.foregroundGreenColor = UIColor()
    }
    
    static func tempestTheme() -> Theme
    {
        var theme = Theme()
        theme.foregroundRedColor = UIColor.redColor()
        theme.foregroundGreenColor = UIColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        theme.foregroundBlueColor = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)
        return theme
    }
}
