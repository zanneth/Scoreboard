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
    private var _session: NSURLSession
    
    init(baseURL: NSURL)
    {
        self.baseURL = baseURL
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        _session = NSURLSession(configuration: config)
    }
    
    func fetchGames(completion: [Game] -> Void)
    {
        let url = self.baseURL.URLByAppendingPathComponent("api").URLByAppendingPathComponent("games")
        let task = _session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var games: [Game] = []
            
            if data != nil {
                games = XionDataSource._parseGames(data!)
            } else {
                print("Error fetching games data. \(error)")
            }
            
            completion(games)
        })
        task.resume()
    }
    
    // MARK: Internal
    
    internal static func _parseGames(data: NSData) -> [Game]
    {
        var games: [Game] = []
        
        if let responseDict = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as? NSDictionary {
            if let gameDicts = responseDict["games"] as? NSArray {
                for gameDictObj in gameDicts {
                    if let gameDict = gameDictObj as? NSDictionary {
                        let game = Game(response: gameDict)
                        games.append(game)
                    }
                }
            }
        } else {
            print("Error parsing games response data.");
        }
        
        return games
    }
}
