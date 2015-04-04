//
//  MainMenuViewController.swift
//  Warfare
//
//  Created by Harry Simmonds on 2015-03-03.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        // Set MatchHelper's view controller
        MatchHelper.sharedInstance().vc = self
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
        self.performSegueWithIdentifier("mainToGameSegue", sender: self)
    }

    func segueToMapSelectionViewController() {
        self.performSegueWithIdentifier("mainToMapSegue", sender: self)
    }

    @IBAction func unwindFromMapSelection(sender: UIStoryboardSegue) {

    }

    @IBAction func unwindFromGame(sender: UIStoryboardSegue) {
        
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
