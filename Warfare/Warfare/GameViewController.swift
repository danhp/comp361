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

    @IBOutlet weak var recruitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    @IBOutlet weak var combineButton: UIBarButtonItem!
    @IBOutlet weak var upgradeButton: UIBarButtonItem!
    @IBOutlet weak var buildButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var nextUnitButton: UIBarButtonItem!
    @IBOutlet weak var nextVillageButton: UIBarButtonItem!
    
    
    @IBAction func nextUnitButtonTapped(sender: AnyObject) {
        var tile = GameEngine.Instance.getNextAvailableUnit()
    }
    
    @IBAction func nextVillageButtonTapped(sender: AnyObject) {
        var tile = GameEngine.Instance.getNextAvailableVillage()
    }
    
    @IBAction func recruitButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }
        GameEngine.Instance.map?.resetColor()

        var tileSelected = GameEngine.Instance.map?.selected

        if tileSelected?.owner == nil || tileSelected?.owner.player !== GameEngine.Instance.game?.currentPlayer { return }

        if let t = tileSelected {
            GameEngine.Instance.recruitUnit(t, type: Constants.Types.Unit.Peasant)
            Hud.Instance.update()
        }

        GameEngine.Instance.map?.draw()
    }

    @IBAction func validateButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()
        let dest = GameEngine.Instance.map?.selected
        GameEngine.Instance.moveUnit(tileSource! , to: dest!)
        Hud.Instance.update()
        validateButton.hidden = true
        cancelButton.hidden = true
        GameEngine.Instance.map?.draw()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()
        validateButton.hidden = true
        cancelButton.hidden = true
        GameEngine.Instance.map?.draw()
    }

    @IBAction func menuButtonTapped(sender: AnyObject) {

    }

    @IBAction func moveButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer != nil) { return }
        GameEngine.Instance.map?.resetColor()

        tileSource = GameEngine.Instance.map?.selected

        if let unit = (tileSource)!.unit {
            if (tileSource)!.owner.player === GameEngine.Instance.game?.currentPlayer
                        && !unit.disabled {
                if let tiles = GameEngine.Instance.map?.getAccessibleRegion(tileSource!) {
                    for t in tiles {
                        t.lighten = true
                    }
                }

                validateButton.hidden = false
                cancelButton.hidden = false
            }
        }

        GameEngine.Instance.map?.draw()
    }

    @IBAction func buildButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()

        GameEngine.Instance.map?.draw()
    }

    @IBAction func upgradeButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }
        GameEngine.Instance.map?.resetColor()

        let selectedTile = GameEngine.Instance.map?.selected
        if selectedTile?.owner.player !== GameEngine.Instance.game?.currentPlayer { return }

        if selectedTile?.village != nil {
            GameEngine.Instance.upgradeVillage(selectedTile!)
        } else if selectedTile?.unit != nil {
            GameEngine.Instance.upgradeUnit(selectedTile!, newLevel: Constants.Types.Unit.Infantry)
        }

        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
    }

    @IBAction func combineButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()
        GameEngine.Instance.map?.draw()
    }


    @IBAction func skipButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }
        GameEngine.Instance.map?.resetColor()

        GameEngine.Instance.beginTurn()

        MatchHelper.sharedInstance().advanceMatchTurn()

        GameEngine.Instance.map?.resetColor()
        GameEngine.Instance.map?.draw()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
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
            skView.showsFPS = true
//            skView.showsNodeCount = true
//            skView.showsDrawCount = true

            validateButton.hidden = true
            cancelButton.hidden = true
            recruitButton.hidden = false

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill

            skView.presentScene(scene)

            GameEngine.Instance.scene = scene
        }
    }
    
    func unitSelected() {
        buildButton.enabled = false
        upgradeButton.enabled = true
        moveButton.enabled = true
        combineButton.enabled = true
    }
    
    func structureSelected() {
        buildButton.enabled = false
        upgradeButton.enabled = true
        moveButton.enabled = false
        combineButton.enabled = false
    }
    
    func neutralSelected() {
        upgradeButton.enabled = false
        combineButton.enabled = false
    }
    
    func hidePlayerButtons() {
        buildButton.enabled = false
        upgradeButton.enabled = false
        moveButton.enabled = false
        combineButton.enabled = false
        skipButton.enabled = false
        
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
