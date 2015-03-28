//
//  MainMenuViewController.swift
//  Warfare
//
//  Created by Harry Simmonds on 2015-03-03.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set MatchHelper's view controller
        MatchHelper.sharedInstance().vc = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func joinMatch(sender: AnyObject) {
        // Show join match screen
        MatchHelper.sharedInstance().joinMatch()
    }

    func segueToGameViewController() {
        self.performSegueWithIdentifier("gameViewControllerSegue", sender: self)
    }

    func segueToMapSelectionViewController() {
        self.performSegueWithIdentifier("mapSelectionViewControllerSegue", sender: self)
    }

    func dismissViewController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
