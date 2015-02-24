//
//  MatchHelper.swift
//  Warfare
//
//  Created by Justin Domingue on 2015-02-16.
//  Copyright (c) 2015 Justin Domingue. All rights reserved.
//

import Foundation
import GameKit

private var sharedHelper: MatchHelper?

class MatchHelper: NSObject, GKTurnBasedMatchmakerViewControllerDelegate {
    var gameCenterAvailable: Bool {
        // Check for presence of GKLocalPlayer API
        let gClass: AnyClass? = NSClassFromString("GKLocalPlayer")
        
        // NOTE: No need to check if device is iOS 4.1 or higher
        return gClass != nil
    }
    var userAuthenticated = false
    
    var vc: GameViewController?
    
    override init() {
        super.init()
        
        if self.gameCenterAvailable {
            let nc = NSNotificationCenter.defaultCenter()
            nc.addObserver(self, selector: Selector("authenticationChanged"), name:GKPlayerAuthenticationDidChangeNotificationName, object: nil)
        }
        
    }
    
    class func sharedInstance() -> MatchHelper {
        if sharedHelper == nil {
            sharedHelper = MatchHelper()
        }
        
        return sharedHelper!
    }
    
    // MARK: - Authentication
    
    func authenticateLocalUser() {
        if !gameCenterAvailable { return }
        
        if !GKLocalPlayer.localPlayer().authenticated {
            var localPlayer = GKLocalPlayer.localPlayer()
            localPlayer.authenticateHandler = {(viewController : UIViewController!, error : NSError!) -> Void in
                if ((viewController) != nil) {
                    self.vc?.presentViewController(viewController, animated: true, completion: nil)
                }else{
                    println((GKLocalPlayer.localPlayer().authenticated))
                    self.userAuthenticated = true
                }
            }
        }
    }
    
    func authenticationChanged() {
        if GKLocalPlayer.localPlayer().authenticated && !self.userAuthenticated {
            self.userAuthenticated = true
        } else if !GKLocalPlayer.localPlayer().authenticated && self.userAuthenticated {
            self.userAuthenticated = false
        }
    }
    
    // MARK: - GKMatch
    
    func joinMatch() {
        if self.userAuthenticated {
            println("Joining match")

            // Create match request
            let request = GKMatchRequest()
            request.minPlayers = 3
            request.maxPlayers = 3
            request.defaultNumberOfPlayers = 3
            
            let mmvc = GKTurnBasedMatchmakerViewController(matchRequest: request)
            mmvc.turnBasedMatchmakerDelegate = self
            self.vc?.presentViewController(mmvc, animated: true, completion: nil)
        }
    }
    
    func turnBasedMatchmakerViewControllerWasCancelled(controller: GKTurnBasedMatchmakerViewController!) {
        self.vc?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(controller: GKTurnBasedMatchmakerViewController!, didFindMatch match: GKTurnBasedMatch!) {
        self.vc?.dismissViewControllerAnimated(true, completion: nil)
        self.vc?.showGamePlayScene()
    }
    
    func turnBasedMatchmakerViewController(controller: GKTurnBasedMatchmakerViewController!, playerQuitForMatch match: GKTurnBasedMatch!) {
        
    }
    
    func turnBasedMatchmakerViewController(controller: GKTurnBasedMatchmakerViewController!, didFailWithError: NSError!) {
        self.vc?.dismissViewControllerAnimated(true, completion: nil)
    }
}