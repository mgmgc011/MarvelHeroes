//
//  Superhero.swift
//  Marvel Guide
//
//  Created by Mingu Chu on 9/2/16.
//  Copyright © 2016 Mingu Chu. All rights reserved.
//

import Foundation
import UIKit

class Superhero {
    
    var charId: Int
    var name: String
    var description: String
    var imagePath: String?
    var imageLoaded: UIImage?
//    var detailURL: String?
    
    var hasPhoto: Bool {
        get {
            return imagePath!.containsString("image_not_avaliable")
        }
    }
    
    
    init(dictionary: [String: AnyObject]) {
        charId = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        description = dictionary["description"] as! String
        
        let imageDict = dictionary["thumbnail"] as! [String: String]
        imagePath = imageDict["path"]! + "." + imageDict["extension"]!
        
    }
    
    func loadImage(completion: (image: UIImage?, superhero: Superhero) -> Void) {
        if imagePath == nil {
            completion(image: nil, superhero: self)
            return
        }
        if let imageloadedUnw = imageLoaded {
            completion(image: imageloadedUnw, superhero: self)
        } else {
            getDataFromUrl(NSURL(string: imagePath!)!, completion: { (data, response, error) in
                if let dataUnw = data {
                    self.imageLoaded = UIImage(data: dataUnw)
                    completion(image: self.imageLoaded, superhero: self)
                } else {
                    completion(image: nil, superhero: self)
                }
            })
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
}




