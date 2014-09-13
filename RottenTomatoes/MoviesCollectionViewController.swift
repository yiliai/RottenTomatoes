//
//  MoviesCollectionViewController.swift
//  RottenTomatoes
//
//  Created by Yili Aiwazian on 9/11/14.
//  Copyright (c) 2014 Yili Aiwazian. All rights reserved.
//

import UIKit

let LIGHT_GRAY = UIColor(white: 0.65, alpha: 1.0)
let BG_GRAY = UIColor(white: 0.96, alpha: 1.0)

class MoviesCollectionViewController: UIViewController, UICollectionViewDataSource {

    var moviesArray :NSArray?
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moviesCollectionView.backgroundColor = BG_GRAY
            
        loadRottenTomatoesData()
    }

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if (moviesArray != nil) {
            return moviesArray!.count
        }
        else {
            return 0
        }
    }
    
    func loadRottenTomatoesData() {
        let YourApiKey = "cvyj5jz6rkzkscxus99qwvay"
        let RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=" + YourApiKey
        let request = NSMutableURLRequest(URL: NSURL.URLWithString(RottenTomatoesURLString))
        
        println("making the request")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response, data, error) in
            println("\(error)")
            var errorValue: NSError? = nil
            let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue)
            if parsedResult != nil {
                let dictionary = parsedResult! as NSDictionary
                self.moviesArray = dictionary["movies"] as? NSArray
                self.moviesCollectionView.reloadData()
                println("done loading data")
            }
        })
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(145.0, 270.0)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCollectionCell", forIndexPath: indexPath) as MovieCollectionViewCell
        
        let movieDictionary = self.moviesArray![indexPath.row] as NSDictionary
        cell.movieNameLabel.text = movieDictionary["title"] as NSString
        cell.movieNameLabel.frame = CGRectMake(8,210,128,50)
        cell.movieNameLabel.numberOfLines = 0
        cell.movieNameLabel.sizeToFit()
        let h_offset = cell.movieNameLabel.frame.origin.y + cell.movieNameLabel.frame.height + 5
        if let mpaa_rating = movieDictionary["mpaa_rating"] as? NSString {
            cell.movieRatingLabel.text = " \(mpaa_rating) "
            cell.movieRatingLabel.textColor = LIGHT_GRAY
            cell.movieRatingLabel.layer.borderWidth = 1.0
            cell.movieRatingLabel.layer.borderColor = LIGHT_GRAY.CGColor
            cell.movieRatingLabel.frame = CGRectMake(8,h_offset,128,40)
            cell.movieRatingLabel.sizeToFit()
        }
        if let runtime = movieDictionary["runtime"] as? NSInteger {
            let x_offset = cell.movieRatingLabel.frame.origin.x + cell.movieRatingLabel.frame.width + 10
            cell.movieRuntimeLabel.text = "\(runtime) min"
            cell.movieRuntimeLabel.textColor = LIGHT_GRAY
            cell.movieRuntimeLabel.frame = CGRectMake(x_offset,h_offset,128,40)
            cell.movieRuntimeLabel.sizeToFit()
        }
        let ratings = movieDictionary["ratings"] as NSDictionary
        let critics_score = ratings["critics_score"] as NSInteger
        if (critics_score > 50) {
            cell.ratingImage.image = UIImage(named: "rating_fresh")
        }
        else {
            cell.ratingImage.image = UIImage(named: "rating_rotten")
        }
        var x_offset = cell.movieRuntimeLabel.frame.origin.x + cell.movieRuntimeLabel.frame.width + 10
        cell.ratingImage.frame = CGRectMake(x_offset,h_offset-2,15,15)
        x_offset += cell.ratingImage.frame.width + 2

        cell.ratingLabel.text = "\(String(critics_score))%"
        cell.ratingLabel.textColor = LIGHT_GRAY
        cell.ratingLabel.frame = CGRectMake(x_offset,h_offset,128,40)
        cell.ratingLabel.sizeToFit()
        
        
        
        let moviePosters = movieDictionary["posters"] as NSDictionary
        var thumbnailURL = moviePosters["thumbnail"] as String
        thumbnailURL = thumbnailURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_det.jpg", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        cell.moviePosterImage.setImageWithURL(NSURL.URLWithString(thumbnailURL as NSString))
        
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.masksToBounds = true;
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor
        cell.contentView.layer.borderWidth = 1.0
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailsView" {
            let detailsViewController: MovieDetailsViewController = segue.destinationViewController as MovieDetailsViewController
            let indexPath = self.moviesCollectionView.indexPathsForSelectedItems()[0] as NSIndexPath
            detailsViewController.movieDictionary = self.moviesArray![indexPath.row] as NSDictionary
        }
    }
    
}
