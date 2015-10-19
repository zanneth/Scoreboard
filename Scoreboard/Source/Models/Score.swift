//
//  Score.swift
//  Scoreboard
//
//  Created by Charles Magahern on 9/27/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

import Foundation

class Score: CustomStringConvertible {
    var identifier:     Int64   = 0
    var scoreValue:     Int64   = 0
    var dateCreated:    NSDate  = NSDate()
    var playerName:     String  = ""
    
    init()
    {}
    
    init(response: NSDictionary)
    {
        if let identifier = response["id"] as? NSNumber {
            self.identifier = identifier.longLongValue
        }
        
        if let scoreValue = response["scoreValue"] as? NSNumber {
            self.scoreValue = scoreValue.longLongValue
        }
        
        if let playerName = response["playerName"] as? NSString {
            self.playerName = String(playerName)
        }
        
        if let dateCreatedTimestamp = response["dateCreated"] as? NSNumber {
            self.dateCreated = NSDate(timeIntervalSince1970: (dateCreatedTimestamp.doubleValue / 1000))
        }
    }
    
    var description: String {
        get
        {
            return "id=\(self.identifier) \(self.scoreValue) \"\(self.playerName)\""
        }
    }
}
