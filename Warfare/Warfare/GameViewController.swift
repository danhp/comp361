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
    var tileDest : Tile?

    @IBOutlet weak var menuButton: UIButton!

    @IBOutlet weak var nextUnitButton: UIButton!
    @IBOutlet weak var nextVillageButton: UIButton!

    @IBOutlet weak var attackButton: UIButton!
    @IBOutlet weak var buildButton: UIButton!
    @IBOutlet weak var combineButton: UIButton!
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var recruitButton: UIButton!
    @IBOutlet weak var upgradeButton: UIButton!

    @IBOutlet weak var peasantButton: UIButton!
    @IBOutlet weak var infantryButton: UIButton!
    @IBOutlet weak var soldierButton: UIButton!
    @IBOutlet weak var knightButton: UIButton!
    @IBOutlet weak var canonButton: UIButton!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!

    @IBOutlet weak var roadButton: UIButton!
    @IBOutlet weak var towerButton: UIButton!
    @IBOutlet weak var meadowButton: UIButton!

    @IBOutlet weak var endTurnButton: UIButton!

    var state : Constants.UI.State = .NothingPressed

    func showGamePlayScene() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            //            skView.showsNodeCount = true
            //            skView.showsDrawCount = true

            self.hideActionButtons()

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill

            skView.presentScene(scene)

            GameEngine.Instance.scene = scene
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideBuildOptions()
        self.hideUnitSelection()

        validateButton.hidden = true
        cancelButton.hidden = true

        // Set MatchHelper's view controller
        MatchHelper.sharedInstance().vc = self

        self.showGamePlayScene()
    }

    @IBAction func nextUnitButtonTapped(sender: AnyObject) {
        if let tile = GameEngine.Instance.getNextAvailableUnit() {
            GameEngine.Instance.map?.centerAround(tile)
        }
    }

    @IBAction func nextVillageButtonTapped(sender: AnyObject) {
        if let tile = GameEngine.Instance.getNextAvailableVillage() {
            GameEngine.Instance.map?.centerAround(tile)
        }
    }

    @IBAction func attackButtonTapped(sender: AnyObject) {
        self.betweenPresses()
        self.state = .AttackPressed
        self.tileSource = GameEngine.Instance.map?.selected
        GameEngine.Instance.map?.resetColor()

        self.hideButton(attackButton)
        let seed = GameEngine.Instance.map?.selected
        if let tiles = GameEngine.Instance.map?.getAttackableRegion(seed!) {
            for t in tiles {
                t.lighten = true
            }
        }
        GameEngine.Instance.map?.draw()
    }

    @IBAction func buildButtonTapped(sender: AnyObject) {
        self.betweenPresses()
        if let tile = GameEngine.Instance.map?.selected {
            if tile.village != nil {
                self.showButton(towerButton)
            }
            else if tile.unit != nil {
                self.showButton(roadButton)
                self.showButton(meadowButton)
            }
        }

        self.hideButton(validateButton)

        self.tileSource = GameEngine.Instance.map?.selected
    }

    @IBAction func towerButtonTapped(sender: AnyObject) {
        self.betweenPresses()
        self.state = .BuildTowerPressed
        self.hideButton(towerButton)

        GameEngine.Instance.map?.resetColor()
        if let tiles = tileSource?.owner.controlledTiles {
            for t in tiles {
                if t.isBuildable() {
                    t.lighten = true
                }
            }
        }
        GameEngine.Instance.map?.draw()
    }

    @IBAction func roadButtonTapped(sender: AnyObject) {
        self.betweenPresses()
        self.state = .BuildRoadPressed
        self.hideButton(roadButton)
        self.hideButton(meadowButton)

        GameEngine.Instance.map?.resetColor()
        if let tiles = GameEngine.Instance.map?.getBuildableRegion(tileSource!) {
            for t in tiles {
                t.lighten = true
            }
        }
        GameEngine.Instance.map?.draw()
    }

    @IBAction func meadowButtonTapped(sender: AnyObject) {
        self.betweenPresses()
        self.state = .BuildMeadowPressed
        self.hideButton(meadowButton)
        self.hideButton(roadButton)

        GameEngine.Instance.map?.resetColor()
        if let tiles = GameEngine.Instance.map?.getBuildableRegion(tileSource!) {
            for t in tiles {
                t.lighten = true
            }
        }
        GameEngine.Instance.map?.draw()
    }

    @IBAction func moveButtonTapped(sender: AnyObject) {
        self.betweenPresses()
        self.state = .MovePressed
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }
        GameEngine.Instance.map?.resetColor()

        self.tileSource = GameEngine.Instance.map?.selected

        if let unit = (tileSource)!.unit {
            if (tileSource)!.owner.player === GameEngine.Instance.game?.currentPlayer
                        && !unit.disabled {
                if let tiles = GameEngine.Instance.map?.getAccessibleRegion(tileSource!) {
                    for t in tiles {
                        t.lighten = true
                    }
                }

                self.validateButton.hidden = false
                self.cancelButton.hidden = false
            }
        }

        GameEngine.Instance.map?.draw()
    }

    @IBAction func upgradeButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }
        GameEngine.Instance.map?.resetColor()

        self.tileSource = GameEngine.Instance.map?.selected
        let selectedTile = GameEngine.Instance.map?.selected
        if !(selectedTile?.isBelongsToLocal())! { return }

        if selectedTile?.village != nil {
            GameEngine.Instance.upgradeVillage(selectedTile!)
        } else if selectedTile?.unit != nil {
            self.showUpgradeOptions(selectedTile!)
        }

        Hud.Instance.update()
        self.update(selectedTile!)
        self.hideActionButtons()
        GameEngine.Instance.map?.draw()
    }

    @IBAction func combineButtonTapped(sender: AnyObject) {
        tileSource = GameEngine.Instance.map?.selected

        if !(tileSource?.isBelongsToLocal())! { return }
        if tileSource?.unit == nil { return }

        state = .CombinePressed
        betweenPresses()
    }

    @IBAction func endTurnButtonTapped(sender: AnyObject) {
        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! { return }

        MatchHelper.sharedInstance().advanceMatchTurn()

        GameEngine.Instance.map?.resetColor()
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

    @IBAction func peasantButtonTapped(sender: AnyObject) {
        GameEngine.Instance.recruitUnit(tileSource!, type: Constants.Types.Unit.Peasant)
        self.hideUnitSelection()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
    }
    @IBAction func infantryButtonTapped(sender: AnyObject) {
        GameEngine.Instance.upgradeUnit(tileSource!, newLevel: Constants.Types.Unit.Infantry)
        self.hideUnitSelection()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
    }
    @IBAction func soldierButtonTapped(sender: AnyObject) {
        GameEngine.Instance.upgradeUnit(tileSource!, newLevel: Constants.Types.Unit.Soldier)
        self.hideUnitSelection()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
    }
    @IBAction func knightButtonTapped(sender: AnyObject) {
        GameEngine.Instance.upgradeUnit(tileSource!, newLevel: Constants.Types.Unit.Knight)
        self.hideUnitSelection()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
    }
    @IBAction func canonButtonTapped(sender: AnyObject) {
        GameEngine.Instance.recruitUnit(tileSource!, type: Constants.Types.Unit.Canon)
        self.hideUnitSelection()
        Hud.Instance.update()
        GameEngine.Instance.map?.draw()
    }

    @IBAction func validateButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()
        let dest = GameEngine.Instance.map?.selected
        if self.state == .AttackPressed {
            GameEngine.Instance.attack(tileSource!, to: dest!)
        }else if self.state == .BuildRoadPressed {
            GameEngine.Instance.buildRoad(tileSource!, on: dest!)
        }
        else if self.state == .BuildMeadowPressed {
            GameEngine.Instance.startCultivating(tileSource!, on: dest!)
        }
        else if self.state == .BuildTowerPressed {
            GameEngine.Instance.buildTower(dest!)
        }
        else if self.state == .MovePressed {
            GameEngine.Instance.moveUnit(tileSource! , to: dest!)
        }
        else if self.state == .CombinePressed {
            if dest?.unit != nil {
                GameEngine.Instance.combineUnit(tileSource!, tileB: dest!)
            }
        }

        Hud.Instance.update()
        validateButton.hidden = true
        cancelButton.hidden = true
        GameEngine.Instance.map?.draw()

        self.state = .NothingPressed
        self.update(dest!)
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        GameEngine.Instance.map?.resetColor()
        self.hideButton(validateButton)
        self.hideButton(cancelButton)
        GameEngine.Instance.map?.selected = tileSource!
        GameEngine.Instance.map?.draw()
        state = .NothingPressed

        self.update((GameEngine.Instance.map?.selected)!)
        self.hideBuildOptions()
    }

    func update(tile: Tile) {
        self.hideActionButtons()

        if !(GameEngine.Instance.game?.localIsCurrentPlayer)! {
            self.hidePlayerButtons()
        } else if !tile.isBelongsToLocal() {
            self.neutralSelected()
        } else if tile.village != nil {
            if !tile.owner.disaled {
                self.villageSelected(tile)
            } else {
                self.neutralSelected()
            }
        } else if let unit = tile.unit {
            if !unit.disabled {
                self.unitSelected(tile)
            } else {
                self.neutralSelected()
            }
        } else {
            self.neutralSelected()
        }
    }

    // buttons that are shown after certain selection
    func unitSelected(tile: Tile) {
        if self.state != .NothingPressed { return }

        if tile.unit?.type == Constants.Types.Unit.Peasant {
            self.showButton(buildButton)
        } else if tile.unit?.type == Constants.Types.Unit.Canon {
            self.showButton(attackButton)
        }
        if tile.unit?.type.rawValue < Constants.Types.Unit.Knight.rawValue {
            self.showButton(upgradeButton)
            self.showButton(combineButton)
        }
        self.showButton(moveButton)

        self.hideButton(recruitButton)
    }

    func villageSelected(tile: Tile) {
        if self.state != .NothingPressed { return }

        if tile.owner.type != Constants.Types.Village.Hovel {
            self.showButton(buildButton)
        }
        if tile.owner.type.rawValue < Constants.Types.Village.Castle.rawValue {
            self.showButton(upgradeButton)
        }
        self.showButton(recruitButton)

        self.hideButton(moveButton)
        self.hideButton(combineButton)
    }

    func neutralSelected() {
        self.hideButton(buildButton)
        self.hideButton(combineButton)
        self.hideButton(moveButton)
        self.hideButton(recruitButton)
        self.hideButton(upgradeButton)
    }

    func hidePlayerButtons() {
        self.hideActionButtons()

        self.hideButton(nextUnitButton)
        self.hideButton(nextVillageButton)
        self.hideButton(endTurnButton)
    }

    func betweenPresses() {
        self.showButton(cancelButton)
        self.showButton(validateButton)

        self.hideActionButtons()
        self.hideBuildOptions()
    }

    func finishButtonPress() {
        self.hideButton(towerButton)
        self.hideButton(roadButton)
        self.hideButton(meadowButton)

        self.update((GameEngine.Instance.map?.selected)!)
    }

    func hideActionButtons() {
        self.hideButton(attackButton)
        self.hideButton(buildButton)
        self.hideButton(combineButton)
        self.hideButton(moveButton)
        self.hideButton(recruitButton)
        self.hideButton(upgradeButton)
    }

    func showUpgradeOptions(tile: Tile) {
        if tile.unit == nil { return }

        if tile.unit?.type == Constants.Types.Unit.Peasant {
            self.showButton(infantryButton)
            self.showButton(soldierButton)
            self.showButton(knightButton)
        } else if tile.unit?.type == Constants.Types.Unit.Infantry {
            self.showButton(soldierButton)
            self.showButton(knightButton)
        } else if tile.unit?.type == Constants.Types.Unit.Soldier {
            self.showButton(knightButton)
        }
    }

    func hideUnitSelection() {
        self.hideButton(peasantButton)
        self.hideButton(infantryButton)
        self.hideButton(soldierButton)
        self.hideButton(knightButton)
        self.hideButton(canonButton)
    }

    func hideBuildOptions() {
        self.hideButton(roadButton)
        self.hideButton(meadowButton)
        self.hideButton(towerButton)
    }

    // MARK: Visual helpers
    func showButton(button: UIButton) {
        button.hidden = false
        button.enabled = true
    }

    func hideButton(button: UIButton) {
        button.hidden = true
        button.enabled = false
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
