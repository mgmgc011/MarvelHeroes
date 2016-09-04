//
//  HeroListTableViewCell.swift
//  MarvelHeroes
//
//  Created by Mingu Chu on 9/4/16.
//  Copyright © 2016 Mingu Chu. All rights reserved.
//

import UIKit

class HeroListTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var superheroLinked: Superhero!
    
    
    override func prepareForReuse() {
        heroImage.image = nil
        superheroLinked = nil
    }
    
    func configureWithHero(superhero: Superhero) {
        nameLabel.text = superhero.name
        superheroLinked = superhero
        
        superhero.loadImage { (image, superheroReturned) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.superheroLinked.charId == superheroReturned.charId {
                    if let imageReturned = image {
                        self.heroImage.image = imageReturned
                    }
                }
                
            })
        }
    }
    
}
