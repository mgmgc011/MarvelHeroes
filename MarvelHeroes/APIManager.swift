//
//  APIManager.swift
//  Marvel Guide
//
//  Created by Mingu Chu on 9/2/16.
//  Copyright © 2016 Mingu Chu. All rights reserved.
//

import UIKit
import AFNetworking

typealias errorHandler = (requestOperation: AFHTTPRequestOperation!, error: NSError!) -> Void


class APIManager {
    
    let operationManager = AFHTTPRequestOperationManager()
    let defaultPageSize = 12
    
    
    private lazy var publicKey: String = {
        let path = NSBundle.mainBundle().pathForResource("MarvelAPIKeys", ofType: "plist")
        let keys = NSDictionary(contentsOfFile: path!)
        return keys!.objectForKey("PUBLIC_API_KEY") as! String
    }()
    
    private lazy var privateKey: String = {
        let path = NSBundle.mainBundle().pathForResource("MarvelAPIKeys", ofType: "plist")
        let keys = NSDictionary(contentsOfFile: path!)
        return keys!.objectForKey("PRIVATE_API_KEY") as! String
    }()
    
    private lazy var getCharactersURL: String = {
        return self.urlForRequest(requestKey:"GET_CHARACTERS")
    }()
    
    private lazy var getComicsURL: String = {
        return self.urlForRequest(requestKey:"GET_COMICS")
    }()
    
    private lazy var getSeriesURL: String = {
        return self.urlForRequest(requestKey:"GET_SERIES")
    }()
    
    private lazy var getStoriesURL: String = {
        return self.urlForRequest(requestKey:"GET_STORIES")
    }()
    
    private lazy var getEventsURL: String = {
        return self.urlForRequest(requestKey:"GET_EVENTS")
    }()
    
    
    class var sharedInstance: APIManager {
        struct StaticVar {
            static var instance: APIManager!
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&StaticVar.token) {
            StaticVar.instance = APIManager()
        }
        
        return StaticVar.instance
    }
    
    init() {}
    
    func getHeroes(page: Int, success: (operation: AFHTTPRequestOperation!, superheroes: [Superhero]) -> Void, failure: errorHandler) {
        
        let eventURL = String(format: getCharactersURL)
        let timeStamp = NSDate().timeIntervalSince1970.description
        let hash = md5("\(timeStamp)\(privateKey)\(publicKey)")
        let offset = page * defaultPageSize
        
        operationManager.GET(eventURL, parameters: ["apikey": publicKey, "ts" : timeStamp, "hash": hash, "limit": defaultPageSize, "offset": offset], success: { (operation, response) -> Void in
            let data = response["data"]
            let results = data!!["results"]
            
            var heroList = [Superhero]()
            if let heroReturned = results as? [[String: AnyObject]] {
                for hero in heroReturned {
                    let heroToAppend = Superhero(dictionary: hero)
                    heroList.append(heroToAppend)
                }
            }
            success(operation: operation, superheroes: heroList)
            
            }, failure: { (operation, error) -> Void in
                failure(requestOperation: operation, error: error)
        })
        
        
    }
    
    
    
    private func urlForRequest(requestKey requestKey: String) -> String {
        let path = NSBundle.mainBundle().pathForResource("URLs", ofType: "plist")
        let urls = NSDictionary(contentsOfFile: path!)
        let baseURL = urls?.objectForKey("BASE_URL") as! String!
        let relativeURL = urls?.objectForKey(requestKey) as! String!
        
        return baseURL + relativeURL
    }
    
    func md5(string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    
}