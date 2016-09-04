//
//  ViewController.swift
//  MarvelHeroes
//
//  Created by Mingu Chu on 9/3/16.
//  Copyright © 2016 Mingu Chu. All rights reserved.
//

import UIKit
import Foundation

class HeroListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listTableView: UITableView!
    
    let userThumbnailFilter = true
    
    var superheros = [Superhero]()  {
        didSet {
            superheroWithPhoto = superheros.filter({$0.hasPhoto})
        }
    }
    var superheroWithPhoto = [Superhero]()
    var superheroToDisplay: [Superhero]! {
        get {
            if userThumbnailFilter {
                return superheroWithPhoto
            } else {
                return superheros
            }
        }
    }
    
    var apiManager = APIManager.sharedInstance
    var isLoading = false
    var hasMoreCharacters = true
    var page = 0
    let footerPlaceholderView = UIView()
    
    lazy var loadingIndicator: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 70.0))
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        
        activityIndicator.startAnimating()
        activityIndicator.center = footerView.center
        
        footerView.addSubview(activityIndicator)
        
        return footerView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.dataSource = self
        listTableView.delegate = self
        
        isLoading = true
        startLoadingOnFooter(listTableView)
        loadSuperHeros()
        
        
    }
    
    func loadSuperHeros() {
        APIManager.sharedInstance.getHeroes(page, success: { (operation, superheroes) in
            self.didRetriveHeros(superheroes)
        }) { (requestOperation, error) in
            print(error.localizedDescription)
            
            self.didRetrieveHerosError([Superhero]())
        }
        page += 1
    }
    
    func didRetriveHeros(heroList: [Superhero]) {
        if heroList.isEmpty {
            hasMoreCharacters = false
            stopLoadingOnFooter(listTableView)
        } else {
            self.superheros.appendContentsOf(heroList)
            var listRetrivedCount: Int!
            if userThumbnailFilter {
                listRetrivedCount = heroList.filter({$0.hasPhoto}).count
            } else {
                listRetrivedCount = heroList.count
            }
            
            let startIndex = superheroToDisplay.count - listRetrivedCount
            var indexPaths = [NSIndexPath]()
            for i in startIndex ..< superheroToDisplay.count {
                indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            self.listTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            
            if heroList.count == apiManager.defaultPageSize {
                hasMoreCharacters = true
            } else {
                hasMoreCharacters = false
                stopLoadingOnFooter(listTableView)
            }
            listTableView.reloadData()
        }
        isLoading = false
    }
    
    func didRetrieveHerosError(herolist: [Superhero]) {
        isLoading = false
        if superheroToDisplay.count > 0 {
            loadMoreHeros()
        }
    }
    
    func loadMoreHeros() {
        startLoadingOnFooter(listTableView)
        if !hasMoreCharacters {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.stopLoadingOnFooter(self.listTableView)
            })
        } else if !isLoading {
            isLoading = true
            loadSuperHeros()
        }
    }
    
    
    func startLoadingOnFooter(tableView: UITableView) {
        tableView.tableFooterView = loadingIndicator
    }
    func stopLoadingOnFooter(tableView: UITableView) {
        tableView.tableFooterView = footerPlaceholderView
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return superheroToDisplay.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == superheroToDisplay.count - 1 {
            loadMoreHeros()
        }
        
        let cellIdentifier = "HeroListCellID"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HeroListTableViewCell
        
        cell.configureWithHero(superheroToDisplay[indexPath.row])
        
        return cell
    }
    
    
    
}

