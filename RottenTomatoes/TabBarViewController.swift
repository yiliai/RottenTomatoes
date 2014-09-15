//
//  TabBarViewController.swift
//  RottenTomatoes
//
//  Created by Yili Aiwazian on 9/14/14.
//  Copyright (c) 2014 Yili Aiwazian. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    
    //var dvdCollectionViewController = MoviesCollectionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navViewController = UINavigationController()
        self.addChildViewController(navViewController)
        navViewController.tabBarItem = UITabBarItem(title: "DVD", image: UIImage(named: "dvd"), selectedImage: UIImage(named: "dvd"))
        navViewController.navigationBar.barStyle = UIBarStyle.Black
        navViewController.navigationBar.barTintColor = UIColor.orangeColor()
        navViewController.navigationBar.tintColor = UIColor.whiteColor()
        
        println("adding new controller")
        let dvdCollectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("collectionView") as MoviesCollectionViewController
        dvdCollectionViewController.query = TOP_DVD
        dvdCollectionViewController.navigationItem.title = "Top DVD Rentals"
        
        navViewController.addChildViewController(dvdCollectionViewController)
        
        self.tabBar.barTintColor = UIColor.orangeColor()
        self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.barStyle = UIBarStyle.Black
        
        for navController in self.childViewControllers as [UINavigationController] {
            navController.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next-Medium", size: 16)]
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        println(item.title)
        
        
    }

}
