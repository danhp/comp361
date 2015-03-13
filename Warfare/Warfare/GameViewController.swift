//
//  GameViewController.swift
//  warfare
//
//  Created by Justin Domingue on 2015-01-21.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    var tileSource : Tile?
    
    @IBOutlet weak var cancelButton2: UIButton!
    @IBOutlet weak var recruitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var combineButton: UIBarButtonItem!
    @IBOutlet weak var upgradeButton: UIBarButtonItem!
    @IBOutlet weak var buildButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    
    @IBAction func recruitButtonTapped(sender: AnyObject) {
		if !GameEngine.Instance.game.localIsCurrentPlayer { return }
        var tileSelected = GameEngine.Instance.map.selected
        
		if tileSelected?.owner == nil || tileSelected?.owner.player !== GameEngine.Instance.game.currentPlayer { return }

        if let t = tileSelected?.owner {
			GameEngine.Instance.game?.recruitUnit(tileSelected!, type: Constants.Types.Unit.Peasant)
            Hud.Instance.update()
			GameEngine.Instance.map.draw()
        }
    }
    

    @IBAction func cancel2ButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func validateButtonTapped(sender: AnyObject) {
        var dest = GameEngine.Instance.map.selected
        GameEngine.Instance.game?.moveUnit(tileSource! , to: dest!)
		Hud.Instance.update()
		GameEngine.Instance.map.draw()
        validateButton.hidden = true
        cancelButton.hidden = true
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        validateButton.hidden = true
        cancelButton.hidden = true
    }
    
    @IBAction func menuButtonTapped(sender: AnyObject) {
        
    }
 
    @IBAction func infoButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func moveButtonTapped(sender: AnyObject) {
		if !GameEngine.Instance.game.localIsCurrentPlayer { return }

        tileSource = GameEngine.Instance.map.selected
        if tileSource?.unit == nil { return }
		if self.tileSource?.owner.player !== GameEngine.Instance.game.currentPlayer { return }
		if (self.tileSource?.unit)?.currentAction == Constants.Unit.Action.Moved { return }
        
        validateButton.hidden = false
        cancelButton.hidden = false
        
    }
    
    @IBAction func buildButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func upgradeButtonTapped(sender: AnyObject) {
		if !GameEngine.Instance.game.localIsCurrentPlayer { return }

		let selectedTile = GameEngine.Instance.map.selected
		if selectedTile?.owner.player !== GameEngine.Instance.game.currentPlayer { return }

		if selectedTile?.village != nil {
			GameEngine.Instance.game.upgradeVillage(selectedTile!)
		} else if selectedTile?.unit != nil {
			GameEngine.Instance.game.upgradeUnit(selectedTile!, newLevel: Constants.Types.Unit.Infantry)
		}

		Hud.Instance.update()
		GameEngine.Instance.map.draw()
    }
    
    @IBAction func combineButtonTapped(sender: AnyObject) {

    }

    
    @IBAction func skipButtonTapped(sender: AnyObject) {
//		if !GameEngine.Instance.game.localIsCurrentPlayer { return }

        // TODO move to the beginnig of the turn
        GameEngine.Instance.game.beginTurn()

        MatchHelper.sharedInstance().advanceTurn()

		GameEngine.Instance.map.draw()
		Hud.Instance.update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set MatchHelper's view controller
        MatchHelper.sharedInstance().vc = self
        
        self.showGamePlayScene()
    }
    
    func showGamePlayScene() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
//            skView.showsDrawCount = true
            
            validateButton.hidden = true
            cancelButton.hidden = true
            recruitButton.hidden = false
            cancelButton2.hidden = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            GameEngine.Instance.scene = scene
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
