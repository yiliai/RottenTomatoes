//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Yili Aiwazian on 9/10/14.
//  Copyright (c) 2014 Yili Aiwazian. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var moviesTableView: UITableView!
    var moviesArray: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadRottenTomatoesData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (moviesArray != nil) {
            return moviesArray!.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:MovieTableViewCell = tableView.dequeueReusableCellWithIdentifier("movieCell") as MovieTableViewCell
        
        /*if (cell == nil) {
            cell = MovieTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "movieCell")
        }*/

        let movieDictionary = self.moviesArray![indexPath.row] as NSDictionary
        cell.movieNameLabel.text = movieDictionary["title"] as NSString
        
        let moviePosters = movieDictionary["posters"] as NSDictionary
        var thumbnailURL = moviePosters["thumbnail"] as String
        thumbnailURL = thumbnailURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_det.jpg", options: NSStringCompareOptions.LiteralSearch, range: nil)

        cell.moviePosterImage.setImageWithURL(NSURL.URLWithString(thumbnailURL as NSString))
        
        cell.movieDescriptionLabel.text = movieDictionary["synopsis"] as NSString
        
        return cell
    }


    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let detailsViewControl = MovieDetailsViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(detailsViewControl, animated: true)
    }
}
