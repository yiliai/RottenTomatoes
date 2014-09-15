//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Yili Aiwazian on 9/11/14.
//  Copyright (c) 2014 Yili Aiwazian. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieCardView: UIView!
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieSynopsisLabel: UILabel!
    
    
    let GAP_FROM_TOP = CGFloat(400)
    
    var movieDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = movieDictionary["title"] as NSString
        //self.navigationController?.navigationBar.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        //self.navigationController?.navigationBar.translucent = true
        
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        movieCardView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        movieCardView.frame = CGRectMake(0,GAP_FROM_TOP,self.view.frame.width,self.view.frame.height)
        
        // Set movie poster as the background
        moviePosterImage.frame = CGRectMake(0,0,self.view.frame.width,self.view.frame.height)
        if let moviePosters = movieDictionary["posters"] as? NSDictionary {
            
            if let small_thumbnailURL = moviePosters["thumbnail"] as? String {
                println(small_thumbnailURL)
                
                let thumbnailURL = small_thumbnailURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_ori.jpg", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let request = NSURLRequest(URL: NSURL.URLWithString(small_thumbnailURL as NSString))
                
                moviePosterImage.alpha = 0.0
                moviePosterImage.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        self.moviePosterImage.image = image
                        self.moviePosterImage.alpha = 1.0
                    })
                    self.moviePosterImage.setImageWithURL(NSURL.URLWithString(thumbnailURL))
                    }, failure: nil)
            }
        }

        var h_offset = PADDING
        
        // Set movie title and year
        movieNameLabel.text = ""
        if let movieTitle = movieDictionary["title"] as? NSString {
            movieNameLabel.text = String(movieTitle)
        }
        if let movieYear = movieDictionary["year"] as? NSInteger {
            movieNameLabel.text = movieNameLabel.text! + " (" + "\(String(movieYear))" + ")"
        }
        movieNameLabel.frame = CGRectMake(PADDING,h_offset,movieCardView.frame.width-2*PADDING,0)
        movieNameLabel.numberOfLines = 0
        movieNameLabel.sizeToFit()
        h_offset += movieNameLabel.frame.height + PADDING

        if let ratings = movieDictionary["ratings"] as? NSDictionary {
            let critics_score = String(ratings["critics_score"] as NSInteger)
            let critics_rating = ratings["critics_rating"] as NSString
            let audience_score = String(ratings["audience_score"] as NSInteger)
            let audience_rating = ratings["audience_rating"] as NSString
            let rating = "Critics Rating: " + critics_score + "% " + critics_rating + "\nAudience Rating: " + audience_score + "% " + audience_rating
            movieRatingLabel.text = rating
            movieRatingLabel.frame = CGRectMake(PADDING,h_offset,movieCardView.frame.width-2*PADDING,0)
            movieRatingLabel.numberOfLines = 0
            movieRatingLabel.sizeToFit()
            h_offset += movieRatingLabel.frame.height + PADDING
        }
        
        if let synopsis = movieDictionary["synopsis"] as? NSString {
            movieSynopsisLabel.text = synopsis
            movieSynopsisLabel.frame = CGRectMake(PADDING,h_offset,movieCardView.frame.width-2*PADDING,0)
            movieSynopsisLabel.numberOfLines = 0
            movieSynopsisLabel.sizeToFit()
        }
        
        let movieCardHeight = max(movieSynopsisLabel.frame.origin.y + movieSynopsisLabel.frame.height + PADDING, self.view.frame.height - GAP_FROM_TOP)
        
        movieCardView.frame.size = CGSize(width: movieCardView.frame.width, height: movieCardHeight)
        scrollView.contentSize = CGSize(width: movieCardView.frame.width, height: movieCardView.frame.height + GAP_FROM_TOP)
        
    }

}
