//
//  Game.swift
//  Scoreboard
//
//  Created by Charles Magahern on 9/27/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

import Foundation

class Game: CustomStringConvertible {
    var identifier: Int64   = 0
    var name:       String  = ""
    var scores:     [Score] = []
    
    init()
    {}
    
    init(response: NSDictionary)
    {
        if let identifier = response["id"] as? NSNumber {
            self.identifier = identifier.longLongValue
        }
        
        if let name = response["name"] as? NSString {
            self.name = String(name)
        }
        
        if let scoreObjs = response["scores"] as? NSArray {
            for scoreObj in scoreObjs {
                if let scoreDict = scoreObj as? NSDictionary {
                    let score = Score(response: scoreDict)
                    self.scores.append(score)
                }
            }
        }
    }
    
    var description: String {
        get
        {
            return "id=\(self.identifier) \"\(self.name)\" scores=\(self.scores)"
        }
    }
}
