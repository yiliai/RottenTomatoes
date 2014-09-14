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

        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSize(width: 320,height: 1000)
        
        movieCardView.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        movieCardView.frame = CGRectMake(0,GAP_FROM_TOP,320,1000)
                
        let moviePosters = movieDictionary["posters"] as NSDictionary
        let small_thumbnailURL = moviePosters["thumbnail"] as String
    
        let thumbnailURL = small_thumbnailURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_ori.jpg", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        moviePosterImage.setImageWithURL(NSURL.URLWithString(thumbnailURL as NSString))
        //let request = NSURLRequest(URL: NSURL.URLWithString(small_thumbnailURL as NSString))
        
        /*moviePosterImage.setImageWithURLRequest(request),
            placeholderImage: nil,
            success: nil,
            failure: nil)
        */
        
        /*moviePosterImage.setImageWithURLRequest(<#urlRequest: NSURLRequest!#>, placeholderImage: <#UIImage!#>, success: <#((NSURLRequest!, NSHTTPURLResponse!, UIImage!) -> Void)!##(NSURLRequest!, NSHTTPURLResponse!, UIImage!) -> Void#>, failure: <#((NSURLRequest!, NSHTTPURLResponse!, NSError!) -> Void)!##(NSURLRequest!, NSHTTPURLResponse!, NSError!) -> Void#>)*/
        

        moviePosterImage.frame = CGRectMake(0,0,320,568)
        
        var h_offset = CGFloat(10.0)
        
        let movieTitle = movieDictionary["title"] as NSString
        let movieYear = movieDictionary["year"] as NSInteger
        let synopsis = movieDictionary["synopsis"] as NSString
        
        let ratings = movieDictionary["ratings"] as NSDictionary
        let critics_score = String(ratings["critics_score"] as NSInteger)
        let critics_rating = ratings["critics_rating"] as NSString
        let audience_score = String(ratings["audience_score"] as NSInteger)
        let audience_rating = ratings["audience_rating"] as NSString
        let rating = "Critics Rating: " + critics_score + "% " + critics_rating + "\nAudience Rating: " + audience_score + "% " + audience_rating
        
        movieNameLabel.text = "\(movieTitle)" + " (" + "\(String(movieYear))" + ")"
        
        movieNameLabel.frame = CGRectMake(10,h_offset,movieCardView.frame.width-20,50)
        movieNameLabel.numberOfLines = 0
        movieNameLabel.sizeToFit()

        h_offset += movieNameLabel.frame.height + 10

        movieRatingLabel.text = rating
        movieRatingLabel.frame = CGRectMake(10,h_offset,movieCardView.frame.width-20,500)
        movieRatingLabel.numberOfLines = 0
        movieRatingLabel.sizeToFit()

        h_offset += movieRatingLabel.frame.height + 10

        movieSynopsisLabel.text = synopsis
        movieSynopsisLabel.frame = CGRectMake(10,h_offset,movieCardView.frame.width-20,500)
        movieSynopsisLabel.numberOfLines = 0
        movieSynopsisLabel.sizeToFit()
        
        let movieCardHeight = max(movieSynopsisLabel.frame.origin.y + movieSynopsisLabel.frame.height + 10, self.view.frame.height - GAP_FROM_TOP)
        
        movieCardView.frame.size = CGSize(width: movieCardView.frame.width, height: movieCardHeight)
        scrollView.contentSize = CGSize(width: movieCardView.frame.width, height: movieCardView.frame.height + GAP_FROM_TOP)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
