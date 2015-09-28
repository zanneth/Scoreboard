//
//  XionDataSource.swift
//  Scoreboard
//
//  Created by Charles Magahern on 9/27/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

import Foundation

class XionDataSource {
    var         baseURL: NSURL
    private var session: NSURLSession
    
    init(baseURL: NSURL)
    {
        self.baseURL = baseURL
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: config)
    }
    
    func fetchGames(completion: [Game] -> Void)
    {
        let url = self.baseURL.URLByAppendingPathComponent("api").URLByAppendingPathComponent("games")
        let task = self.session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            var games: [Game] = []
            
            if let responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: nil) as? NSDictionary {
                if let gameDicts = responseDict["games"] as? NSArray {
                    for gameDictObj in gameDicts {
                        if let gameDict = gameDictObj as? NSDictionary {
                            let game = Game(response: gameDict)
                            games.append(game)
                        }
                    }
                }
            }
            
            completion(games)
        })
        task.resume()
    }
}
