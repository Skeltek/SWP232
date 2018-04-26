//
//  GameViewController.swift
//  Battle of the Stereotypes
//
//  Created by student on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController,GKGameCenterControllerDelegate,GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener {
    // Scene Instanz
    var sceneInstance: GameScene!
    // lokales Match
    var localMatch : GKTurnBasedMatch!
    // Variable ob GameCenter aktiv ist
    var gamecenterEnabled = false
    
    // GKMatchmakerViewControllerDelegate Methoden
    
    // TurnBasedMatchMakerView abgebrochen
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        print("[" + String(describing: self) + "] MatchMakerViewController abgebrochen")
        
        // TODO: Abbrechen sollte nicht erlaubt werden
        self.dismiss(animated:true, completion:nil)
        //findBattleMatch()
    }
    
    // TurnBasedMatchView fehlgeschlagen
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        // TODO: Hier bei Fehlschlag eventuell eine Fehler Meldung ausgeben und es erneut versuchen
        print("[" + String(describing: self) + "] MatchMakerViewController fehlgeschlagen")
        self.dismiss(animated:true, completion:nil)
    }
    
    // TurnBasedMatchmakerView Match gefunden , bereits existierendes Spiel wird beigetreten
    private func turnBasedMatchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        print("[" + String(describing: self) + "] MatchMakerViewController Match gefunden")
        localMatch = match
        // TODO: Ab hier ermöglichen das eigentliche Spiel zu spielen
    }
    
    // aufgerufen wenn der GameCenterViewController beendet wird
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // Gibt den Index des lokalen Spieler zum Match zurück. Falls der Spieler nicht teil des Matches ist, gibt es -1 zurück
    func indexOfLocalPlayer() -> Int {
        if(!gamecenterIsActive() || !gamecenterGameIsRunning()) {
            return -1
        }
        for participant in localMatch.participants! {
            if(participant.player == GKLocalPlayer.localPlayer()) {
                
            }
        }
        return -1
    }
    
    // Gibt an ob der lokale Spieler gerade am Zug ist
    func islocalPlayersTurn() -> Bool
    {
        if(!gamecenterIsActive() || !gamecenterGameIsRunning()) {
            return false
        }
        if(localMatch.currentParticipant?.player == GKLocalPlayer.localPlayer()) {
            return true
        } else {
            return false
        }
    }
    
    // Beendet das Spiel
    func endGame()
    {
        localMatch.endMatchInTurn(withMatch: Data(), completionHandler: nil)
    }
    
    // Prüft ob Gamecenter aktiv ist und gibt false zurück wenn nicht
    func gamecenterIsActive() -> Bool
    {
        if(gamecenterEnabled == false) {
            print("[" + String(describing: self) + "] Spieler ist nicht eingeloggt")
            return false
        } else {
            return true
        }
    }
    
    // Prüft ob ein Spiel am Laufen ist und gibt false zurück wenn nicht
    func gamecenterGameIsRunning() -> Bool
    {
        if(localMatch == nil) {
            print("[" + String(describing: self) + "] Aktion kann nicht ohne ein gestartetes Spiel zu haben ausgeführt werden")
            return false
        } else {
            return true
        }
    }
    
    // Erstelle ein Match Objekt und versuche einem Spiel beizutreten
    func findBattleMatch()
    {
        if(!gamecenterIsActive()) {
            return
        }
        print("[" + String(describing: self) + "] Beitreten eines... Battle Match")
        let matchRequest=GKMatchRequest()
        matchRequest.maxPlayers=2
        matchRequest.minPlayers=2
        matchRequest.defaultNumberOfPlayers=2
        matchRequest.inviteMessage=GKLocalPlayer.localPlayer().displayName! + " würde gerne Battle of the Stereotypes mit dir spielen"
        let matchMakerViewController = GKTurnBasedMatchmakerViewController.init(matchRequest: matchRequest)
        matchMakerViewController.turnBasedMatchmakerDelegate=self as GKTurnBasedMatchmakerViewControllerDelegate
        self.present(matchMakerViewController, animated: true)
    }
    
    // Authentifizierung des lokalen Spielers
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Zeige den Login Screen wenn der Spieler nicht eingeloggt ist
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Wenn Spieler bereits authentifiziert und eingeloggt, lade MatchMaker und GameCenter Funktionen
                self.gamecenterEnabled = true
                localPlayer.register(self)
                self.findBattleMatch()
            } else {
                // 3. Game center nicht auf aktuellem Gerät aktiviert
                self.gamecenterEnabled = false
                print("[" + String(describing: self) + "] Lokaler Spieler konnte nicht autentifiziert werden")
                print(error as Any)
            }
        }
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        localMatch=match
        print("[" + String(describing: self) + "] Turn Event erhalten")
    }
    
    // Beispielmethode wenn der lokale Spieler seinen Zug beendet hat
    func turnEnded(data: Data)
    {
        if(!gamecenterGameIsRunning()) {
            return
        }
        localMatch.endTurn(withNextParticipants: localMatch.participants!, turnTimeout: TimeInterval(0.0), match: Data(), completionHandler: { (error: Error?) in
            if(error == nil ) {
                // Do nothing
            } else {
                print("[" + String(describing: self) + "]" + "Fehler gefunden")
                print(error as Any)
            }
        })
        
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, playerQuitFor match: GKTurnBasedMatch) {
        print("[" + String(describing: self) + "]" + "Match wurde beendet durch Player Quit")
        match.endMatchInTurn(withMatch: Data(), completionHandler: nil)
    }
    
    // Temporäre Funktion um Matches vom GameCenter zu löschen, funktioniert nicht
    func removeGames()
    {
        GKTurnBasedMatch.loadMatches(completionHandler: {(matches: [GKTurnBasedMatch]?, error: Error?) -> Void in
            if(matches == nil) {
                print("Keine Matches in denen der lokale Spieler beigetreten ist gefunden")
                return
            }
            print("Versuche Matches in denen der lokale Spieler beigetreten ist zu löschen...")
            for match in matches.unsafelyUnwrapped {
                print("Match Outcome setzen")
                for participant in match.participants! {
                    participant.matchOutcome = GKTurnBasedMatchOutcome(rawValue: 0)!  }
                match.endMatchInTurn(withMatch: Data(), completionHandler: {(error: Error?) -> Void in
                    print("Error in removeGames")
                    print(error as Any)
                })
            }
        })
    }
    
    override func viewDidLoad() {
        print("[" + String(describing: self) + "] View geladen")
        // Aufrufen von GameCenter Authentifizierung Controller
        authenticateLocalPlayer()
        //removeGames()
        
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                    
                }
                sceneInstance = sceneNode
                sceneNode.viewController = self
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
