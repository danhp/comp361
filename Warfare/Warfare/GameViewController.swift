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


enum State: Int {
    case NothingPressed = 0, BuildPressed, MovePressed, CombinePressed
}

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
    var tileDest : Tile?

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var nextUnitButton: UIButton!
    @IBOutlet weak var nextVillageButton: UIButton!
    @IBOutlet weak var buildButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var endTurnButton: UIButton!
    @IBOutlet weak var combineButton: UIButton!
    @IBOutlet weak var recruitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var roadButton: UIButton!
    @IBOutlet weak var towerButton: UIButton!
    
    var state : State = State.NothingPressed
    
    
    @IBAction func nextUnitButtonTapped(sender: AnyObject) {
        var tile = GameEngine.Instance.getNextAvailableUnit()
        GameEngine.Instance.map?.centerAround(tile!)
    }

    @IBAction func nextVillageButtonTapped(sender: AnyObject) {
        var tile = GameEngine.Instance.getNextAvailableVillage()
        GameEngine.Instance.map?.centerAround(tile!)
    }
    
    @IBAction func buildButtonTapped(sender: AnyObject) {
        roadButton.hidden = false
        towerButton.hidden = false
        
        betweenPresses()
        
        tileSource = GameEngine.Instance.map?.selected
        
        GameEngine.Instance.map?.resetColor()
        GameEngine.Instance.map?.draw()

    }
    
    @IBAction func towerButtonTapped(sender: AnyObject) {
        GameEngine.Instance.buildTower(tileSource!)
        finishButtonPress()
    }
    
    @IBAction func roadButtonTapped(sender: AnyObject) {
        state = State.BuildPressed
    }
    
    @IBAction func moveButtonTapped(sender: AnyObject) {
        state = State.MovePressed
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
        betweenPresses()
        
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
        
        tileSource = GameEngine.Instance.map?.selected
        
        if tileSource?.owner.player !== GameEngine.Instance.game?.currentPlayer {
            return
        }
        
        if tileSource?.village != nil {
            return
        }
        
        if tileSource?.unit != nil {
            state = State.CombinePressed
            betweenPresses()

        }
        
        GameEngine.Instance.map?.resetColor()
        GameEngine.Instance.map?.draw()
    }
    
    @IBAction func endTurnButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }
        GameEngine.Instance.map?.resetColor()
        
        GameEngine.Instance.beginTurn()
        
        MatchHelper.sharedInstance().advanceMatchTurn()
        
        GameEngine.Instance.map?.resetColor()
        GameEngine.Instance.map?.draw()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
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
        
        if state == State.BuildPressed {
              GameEngine.Instance.buildRoad(tileSource!, from: dest!)
        }
        
        else if state == State.MovePressed {
            GameEngine.Instance.moveUnit(tileSource! , to: dest!)
        }
        
        else if state == State.CombinePressed {
            let dest = GameEngine.Instance.map?.selected
            if dest?.unit != nil {
                GameEngine.Instance.combineUnit(tileSource!, tileB: dest!)
            }
            
        }
        
        Hud.Instance.update()
        validateButton.hidden = true
        cancelButton.hidden = true
        GameEngine.Instance.map?.draw()
        
        finishButtonPress()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()
        validateButton.hidden = true
        cancelButton.hidden = true
        GameEngine.Instance.map?.draw()
        finishButtonPress()
        state = State.NothingPressed
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        roadButton.hidden = true
        towerButton.hidden = true
        validateButton.hidden = true
        cancelButton.hidden = true

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
    
    // buttons that are shown after certain selection
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
        endTurnButton.enabled = false
        
    }
    
    func betweenPresses() {
        cancelButton.enabled = true
        cancelButton.hidden = false
        validateButton.enabled = true
        validateButton.hidden = false

        nextUnitButton.enabled = false
        nextVillageButton.enabled = false
        moveButton.enabled = false
        upgradeButton.enabled = false
        recruitButton.enabled = false
        endTurnButton.enabled = false
        buildButton.enabled = false
        combineButton.enabled = false
    }
    
    func finishButtonPress() {
        towerButton.hidden = true
        roadButton.hidden = true
        
        nextUnitButton.enabled = true
        nextVillageButton.enabled = true
        moveButton.enabled = true
        upgradeButton.enabled = true
        recruitButton.enabled = true
        endTurnButton.enabled = true
        buildButton.enabled = true
        combineButton.enabled = true
        cancelButton.enabled = false
        validateButton.enabled = false
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
