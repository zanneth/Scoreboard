//
//  XionDataSource.swift
//  Scoreboard
//
//  Created by Charles Magahern on 9/27/15.
//  Copyright (c) 2015 zanneth. All rights reserved.
//

import Foundation

class XionDataSource {
    var         baseURL:                NSURL
    
    private var _session:               NSURLSession
    private var _currentPollingTasks:   [Int64 : NSURLSessionDataTask]
    
    init(baseURL: NSURL)
    {
        self.baseURL = baseURL
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 0.0
        
        _session = NSURLSession(configuration: config)
        _currentPollingTasks = [Int64 : NSURLSessionDataTask]()
    }
    
    func fetchGames(completion: ([Game], NSError?) -> Void)
    {
        let url = self.baseURL.URLByAppendingPathComponent("api").URLByAppendingPathComponent("games")
        let task = _session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var games: [Game] = []
            
            if data != nil {
                games = XionDataSource._parseGames(data!)
            } else {
                print("Error fetching games data. \(error)")
            }
            
            completion(games, error)
        })
        task.resume()
    }
    
    func pollForGameUpdate(game: Game, completion: (Game?, NSError?) -> Void)
    {
        let url = self.baseURL.URLByAppendingPathComponent("api")
                              .URLByAppendingPathComponent("games")
                              .URLByAppendingPathComponent("poll")
                              .URLByAppendingPathComponent("\(game.identifier)")
        let task = _session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var game: Game? = nil
            if data != nil {
                game = XionDataSource._parseGame(data!)
            }
            completion(game, error)
        })
        
        let existingTask: NSURLSessionDataTask? = _currentPollingTasks[game.identifier];
        if existingTask != nil {
            existingTask?.cancel()
        }
        _currentPollingTasks[game.identifier] = task
        
        task.resume()
    }
    
    func cancelGameUpdatePoll(game: Game)
    {
        let task: NSURLSessionDataTask? = _currentPollingTasks[game.identifier]
        if task != nil {
            task?.cancel()
        }
        _currentPollingTasks.removeValueForKey(game.identifier)
    }
    
    // MARK: Internal
    
    internal static func _parseGame(data: NSData) -> Game?
    {
        var game: Game?
        
        if let responseDict = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as? NSDictionary {
            game = Game(response: responseDict)
        } else {
            print("Error parsing game response data.")
        }
        
        return game
    }
    
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
