//
//  MainMenuViewController.swift
//  Warfare
//
//  Created by Harry Simmonds on 2015-03-03.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation
import UIKit

class MapSelectionViewController: UIViewController {
    
    @IBOutlet weak var confirmationButton: UIButton!
    
    var selectedIndex: Int = 0
    
    @IBOutlet weak var map1: UIImageView!
    @IBOutlet weak var map2: UIImageView!
    @IBOutlet weak var map3: UIImageView!
    
    @IBOutlet weak var selectMistakeLabel: UILabel!
    
    @IBAction func confirmationAction(sender: AnyObject) {
        if selectedIndex == 0 {
            selectMistakeLabel.hidden = false
            return
        }
        GameEngine.Instance.selectedMap = selectedIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set MatchHelper's view controller
        MatchHelper.sharedInstance().vc = self
        
        // add tap gesture to images
        map1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "map1Tapped:"))
        map2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "map2Tapped:"))
        map3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "map3Tapped:"))
        
        selectMistakeLabel.hidden = true
        
    }
    
    func map1Tapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            mapTapped(1)
            map1.highlighted = true
            map2.highlighted = false
            map3.highlighted = false
        }
    }
    
    func map2Tapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            mapTapped(2)
            map1.highlighted = false
            map2.highlighted = true
            map3.highlighted = false
        }
    }
    
    func map3Tapped(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            mapTapped(3)
            map1.highlighted = false
            map2.highlighted = false
            map3.highlighted = true
        }
    }
    
    func mapTapped(index: Int) {
        selectedIndex = index
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segueToGameViewController() {
        self.performSegueWithIdentifier("gameViewControllerSegue", sender: self)
    }
    
}
