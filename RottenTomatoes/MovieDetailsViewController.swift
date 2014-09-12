//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Yili Aiwazian on 9/11/14.
//  Copyright (c) 2014 Yili Aiwazian. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    override func loadView() {
        self.view = UIView (frame: CGRectZero)
        self.view.backgroundColor = UIColor.redColor()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
