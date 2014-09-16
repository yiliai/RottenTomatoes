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
let TOP_MOVIES_IN_THEATERS = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json"
let TOP_DVD = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/current_releases.json"
let PAGE_LIMIT = 10
let PADDING = CGFloat(10)
let MARGIN = CGFloat(8)
let RATING_IMAGE_SIZE = CGFloat(15)
let POSTER_ASPECT_RATIO = CGFloat(54.0/80.0)
let NAV_BAR_HEIGHT = CGFloat(64)
let SEARCH_BAR_HEIGHT = CGFloat(50)

class MoviesCollectionViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate {

    var moviesArray :NSArray?
    var movieSearchResultsArray :NSArray?
    let refreshControl = UIRefreshControl()
    let progressControl = UIActivityIndicatorView()
    let errorLabel = UILabel()
    let errorView = UIView()
    let searchBarView = UIView()
    let searchField = UITextField()
    // Query is by default top movies
    var query = TOP_MOVIES_IN_THEATERS
    var endOfList = false
    
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = BG_GRAY
        moviesCollectionView.backgroundColor = BG_GRAY
        moviesCollectionView.alwaysBounceVertical = true;
        self.view.addSubview(progressControl)
        
        // Initialize the error messages
        errorView.addSubview(errorLabel)
        self.view.addSubview(errorView)
        errorView.hidden = true
        
        // Initialize the search field
        searchBarView.addSubview(searchField)
        self.view.addSubview(searchBarView)
        searchField.addTarget(self, action: "performSearch", forControlEvents: UIControlEvents.EditingChanged)
        showSearchField()
        
        // Load data from Rotten Tomatoes
        loadRottenTomatoesData()
        
        // Pull to refresh
        refreshControl.addTarget(self, action:"refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.moviesCollectionView.addSubview(refreshControl)
        
        // Special handling of the collection view's pan gesture recognizer
        self.moviesCollectionView.panGestureRecognizer.addTarget(self, action:"onPan")
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if (moviesArray == nil) {
            return 0
        }
        else if (searchField.text == "") {
            return moviesArray!.count
        }
        else {
            return (movieSearchResultsArray == nil) ? 0 : movieSearchResultsArray!.count
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSizeMake(145.0, 270.0)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Load more if we're nearing the end of the list, unless it's displaying search results
        if (!endOfList && (indexPath.row > collectionView.numberOfItemsInSection(0) - 2) && movieSearchResultsArray == nil) {
            loadRottenTomatoesData(refresh: false)
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCollectionCell", forIndexPath: indexPath) as MovieCollectionViewCell
        
        // Check to see if the user is searching to return the right item
        var movieDictionary :NSDictionary
        if (searchField.text == "") {
            movieDictionary = self.moviesArray![indexPath.row] as NSDictionary
        }
        else {
            movieDictionary = self.movieSearchResultsArray![indexPath.row] as NSDictionary
        }
        
        // Set the movie title
        var h_offset = CGFloat(cell.frame.width-2)/(POSTER_ASPECT_RATIO)
        
        if let movieTitle = movieDictionary["title"] as? NSString {
            cell.movieNameLabel.text = movieTitle
            cell.movieNameLabel.frame = CGRectMake(MARGIN,h_offset,cell.frame.width-2*MARGIN,0)
            cell.movieNameLabel.numberOfLines = 0
            cell.movieNameLabel.sizeToFit()
        }
        h_offset = cell.movieNameLabel.frame.origin.y + cell.movieNameLabel.frame.height + PADDING/2

        // Set the MPAA rating
        if let mpaa_rating = movieDictionary["mpaa_rating"] as? NSString {
            cell.movieRatingLabel.text = " \(mpaa_rating) "
            cell.movieRatingLabel.textColor = LIGHT_GRAY
            cell.movieRatingLabel.layer.borderWidth = 1.0
            cell.movieRatingLabel.layer.borderColor = LIGHT_GRAY.CGColor
            cell.movieRatingLabel.frame = CGRectMake(MARGIN,h_offset,0,0)
            cell.movieRatingLabel.sizeToFit()
        }
        
        // Set the runtime
        if let runtime = movieDictionary["runtime"] as? NSInteger {
            let x_offset = cell.movieRatingLabel.frame.origin.x + cell.movieRatingLabel.frame.width + PADDING
            cell.movieRuntimeLabel.text = "\(runtime) min"
            cell.movieRuntimeLabel.textColor = LIGHT_GRAY
            cell.movieRuntimeLabel.frame = CGRectMake(x_offset,h_offset,0,0)
            cell.movieRuntimeLabel.sizeToFit()
        }
        
        // Set the critics rating
        if let ratings = movieDictionary["ratings"] as? NSDictionary {
            if let critics_score = ratings["critics_score"] as? NSInteger {
                if (critics_score > 50) {
                    cell.ratingImage.image = UIImage(named: "rating_fresh")
                }
                else {
                    cell.ratingImage.image = UIImage(named: "rating_rotten")
                }
                var x_offset = cell.movieRuntimeLabel.frame.origin.x + cell.movieRuntimeLabel.frame.width + PADDING
                cell.ratingImage.frame = CGRectMake(x_offset,h_offset-2,RATING_IMAGE_SIZE,RATING_IMAGE_SIZE)
                x_offset += cell.ratingImage.frame.width + 2
            
                cell.ratingLabel.text = "\(String(critics_score))%"
                cell.ratingLabel.textColor = LIGHT_GRAY
                cell.ratingLabel.frame = CGRectMake(x_offset,h_offset,0,0)
                cell.ratingLabel.sizeToFit()
            }
        }
        
        // Set the poster image
        if let moviePosters = movieDictionary["posters"] as? NSDictionary {
            if var thumbnailURL = moviePosters["thumbnail"] as? String {
                thumbnailURL = thumbnailURL.stringByReplacingOccurrencesOfString("_tmb.jpg", withString: "_det.jpg", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                fadeInImageFromURL(cell.moviePosterImage, url: NSURL.URLWithString(thumbnailURL as NSString))
            }
        }
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
            detailsViewController.hidesBottomBarWhenPushed = true
        }
    }

    func onPan() {
        let scrollVelocity :CGPoint = moviesCollectionView.panGestureRecognizer.velocityInView(moviesCollectionView.superview)
        if let tabBar = self.tabBarController?.tabBar {
            
            // Show Tab Bar if scrolling back up
            if (scrollVelocity.y > 0.0) {
                if tabBar.frame.origin.y == self.view.frame.height-tabBar.frame.height {
                    return
                }
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    tabBar.frame = CGRectMake(tabBar.frame.origin.x, self.view.frame.height-tabBar.frame.height, tabBar.frame.width, tabBar.frame.height)
                })
            }
            // Hide Tab Bar if scrolling down
            else if (scrollVelocity.y < 0.0) {
                if tabBar.frame.origin.y == self.view.frame.height {
                    return
                }
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    tabBar.frame = CGRectMake(tabBar.frame.origin.x, self.view.frame.height, tabBar.frame.width, tabBar.frame.height)
                })
            }
        }
    }

    func refresh() {
        loadRottenTomatoesData(refresh: true)
    }
    
    // If refresh is set to false, then this will load the next page of the results.
    // If refresh is set to true (by default), then this will refresh the current set of results
    func loadRottenTomatoesData(refresh :Bool = true) {
        let YourApiKey = "cvyj5jz6rkzkscxus99qwvay"
        
        // Calculate the next page number
        var page = 1
        if (moviesArray != nil && !refresh) {
            page = moviesArray!.count/PAGE_LIMIT + 1
        }
        
        let RottenTomatoesURLString = self.query + "?apikey=" + YourApiKey + "&page_limit=" + String(PAGE_LIMIT) + "&page=" + String(page)
        let request = NSMutableURLRequest(URL: NSURL.URLWithString(RottenTomatoesURLString))
        
        println("making the request")
        self.hideErrorMessage()
        
        progressControl.hidden = false
        progressControl.startAnimating()
        progressControl.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        progressControl.color = UIColor.lightGrayColor()
        progressControl.frame = CGRectMake(self.view.frame.width/2-PADDING, self.view.frame.height/2-PADDING, 2*PADDING, 2*PADDING)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response, data, error) in
            
            if (error != nil) {
                let errorInfo = error.userInfo! as NSDictionary
                let errorMessage = errorInfo["NSLocalizedDescription"] as NSString
                self.showErrorMessage(errorMessage, fullscreen: self.moviesCollectionView.numberOfItemsInSection(0)==0)
            }
            if (data != nil) {
                var errorValue: NSError? = nil
                let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue)
                if parsedResult != nil {
                    let dictionary = parsedResult! as NSDictionary
                    if let newArray = dictionary["movies"] as? NSArray {
                        if newArray.count < PAGE_LIMIT {
                            self.endOfList = true
                        }
                        if (self.moviesArray == nil || refresh) {
                            self.moviesArray = newArray
                        }
                        else {
                            self.moviesArray = self.moviesArray?.arrayByAddingObjectsFromArray(newArray)
                        }
                    }
                    self.moviesCollectionView.reloadData()
                    
                    println("done loading data")
                    println(self.moviesArray?.count)
                }
            }
            self.refreshControl.endRefreshing()
            self.progressControl.hidden = true
            // Removing the progress control from the view so that when you pull to refresh, there aren't 2 spinners.
            self.progressControl.removeFromSuperview()
        })
    }
    
    func showErrorMessage(message: String, fullscreen: Bool) {
        
        errorLabel.text = message
        errorLabel.font = UIFont(name: "Avenir Next", size: 14.0)
        errorLabel.numberOfLines = 0
        
        if (fullscreen) {
            errorLabel.textColor = UIColor.blackColor()
            errorLabel.textAlignment = NSTextAlignment.Center
            errorLabel.frame = CGRectMake(PADDING*5, self.view.frame.height/2, self.view.frame.width-PADDING*10, self.view.frame.height)
            errorLabel.sizeToFit()
        }
        else {
            errorLabel.frame = CGRectMake(PADDING, PADDING, self.view.frame.width-2*PADDING, 0)
            errorLabel.textColor = UIColor.whiteColor()
            errorLabel.sizeToFit()
            
            errorView.layer.backgroundColor = UIColor.darkGrayColor().CGColor
            errorView.frame = CGRectMake(0, NAV_BAR_HEIGHT+SEARCH_BAR_HEIGHT, self.view.frame.width, errorLabel.frame.height+20)
            errorView.layer.shadowRadius = 5.0
            errorView.layer.shadowColor = UIColor.darkGrayColor().CGColor
            errorView.layer.shadowOpacity = 1.0
        }
        errorView.hidden = false
    }
    
    func hideErrorMessage() {
        errorView.hidden = true
    }
    
    func fadeInImageFromURL(imageView :UIImageView, url: NSURL) {
        let request = NSURLRequest(URL: url)
        imageView.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
            if (response == nil) {
                imageView.image = image
                return
            }
            imageView.alpha = 0.0
            imageView.image = image
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                imageView.alpha = 1.0
            })
            }, failure: nil)
    }
    
    func showSearchField() {
        searchBarView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.frame.width, SEARCH_BAR_HEIGHT)
        searchBarView.layer.backgroundColor = BG_GRAY.CGColor
        searchBarView.layer.shadowRadius = 5.0
        searchBarView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        searchBarView.layer.shadowOpacity = 1.0
        
        searchField.frame = CGRectMake(PADDING, PADDING, self.view.frame.width-2*PADDING, SEARCH_BAR_HEIGHT-2*PADDING)
        searchField.borderStyle = UITextBorderStyle.RoundedRect
        searchField.font = UIFont(name: "Avenir Next", size: 14.0)
        searchField.placeholder = "Enter search term"
        searchField.autocorrectionType = UITextAutocorrectionType.No
        searchField.returnKeyType = UIReturnKeyType.Done
        searchField.clearButtonMode = UITextFieldViewMode.Always
        searchField.delegate = self
    }
    
    func hideKeyboard() {
        searchField.resignFirstResponder()
    }
    
    func getSearchResults(searchTerm :String) -> NSArray? {
        var resultsArray :NSArray?
        if (moviesArray == nil) {
            return nil
        }
        for movie in moviesArray! as [NSDictionary] {
            let movieTitle = (movie["title"] as NSString).lowercaseString
            
            let wordsInTitle = movieTitle.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " /-()"))
            
            for word in wordsInTitle {
                if word.hasPrefix(searchTerm.lowercaseString) {
                    if resultsArray == nil {
                        resultsArray = NSArray(object: movie)
                    }
                    else {
                        resultsArray = resultsArray?.arrayByAddingObject(movie)
                    }
                    break
                }
            }
        }
        return resultsArray
    }
    
    func performSearch() {
        self.movieSearchResultsArray = self.getSearchResults(searchField.text)        
        moviesCollectionView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
