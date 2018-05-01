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
    // Spielstatus
    var gameState : GameState = GameState()
    
    struct GameState {
        // Entweder setzen oder raten
        var gameStatus = "setzen"
        // Gesetzte Zahlen, wenn -1 dann keine gesetzte Zahl bisher
        var setNumber = [-1, -1]
        // Geratene Zahl, wenn -1 dann keine geratene Zahl bisher
        var betNumber = [-1, -1]
        // Verbleibende Münzen
        var remainingCoins = [3, 3]
    }
    
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
            if(participant.player?.playerID == GKLocalPlayer.localPlayer().playerID) {
                return localMatch.participants!.index(of: participant)!
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
        if(localMatch.currentParticipant?.player?.playerID == GKLocalPlayer.localPlayer().playerID) {
            return true
        } else {
            return false
        }
    }
    
    // Beendet das Spiel
    func endGame()
    {
        localMatch.endMatchInTurn(withMatch: encodeGameState(gameState: gameState), completionHandler: nil)
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
                localPlayer.unregisterAllListeners()
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
        if(match.participants![0].lastTurnDate != nil) {
            let matchData = localMatch.matchData
            localMatch.loadMatchData(completionHandler: nil)
            gameState = decodeGameState(data: matchData!)
            // TODO: Game status sollte später geändert werden da man ja abwechselnd raten und setzen will
            sceneInstance.updateTextLabels()
        }
        print("Betnumber von Spieler 0: " + String(gameState.betNumber[0]))
        print("Betnumber von Spieler 1: " + String(gameState.betNumber[1]))
        print("Setnumber von Spieler 0:" + String(gameState.setNumber[0]))
        print("Setnumber von Spieler 1:" + String(gameState.setNumber[1]))
        print("[" + String(describing: self) + "] Turn Event erhalten")
    }
    
    // Beispielmethode wenn der lokale Spieler seinen Zug beendet hat
    func turnEnded()
    {
        if(!gamecenterGameIsRunning()) {
            return
        }
        print("Turn Ended")
        let currentIndexOfPlayer : Int = (localMatch.participants?.index(of: localMatch.currentParticipant!))!
        var nextParticipant : GKTurnBasedParticipant
        nextParticipant = localMatch.participants![((currentIndexOfPlayer + 1) % (localMatch.participants?.count)!)]
        localMatch.endTurn(withNextParticipants: [nextParticipant], turnTimeout: TimeInterval(3.0), match:         encodeGameState(gameState: gameState), completionHandler: { (error: Error?) in
            if(error == nil ) {
                // Tu nichts
            } else {
                print("[" + String(describing: self) + "]" + "Fehler gefunden")
                print(error as Any)
            }
        })
        
    }
    
    // Alternativer Versuch zum Verpacken, noch nicht getestet
    func encodeGameState(gameState: GameState) -> Data {
        var sendString : String = ""
        let seperator : String = "|"
        sendString = sendString + gameState.gameStatus
        sendString = sendString + seperator
        sendString = sendString + String(gameState.betNumber[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.betNumber[1])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.setNumber[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.setNumber[1])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.remainingCoins[0])
        sendString = sendString + seperator
        sendString = sendString + String(gameState.remainingCoins[1])
        return sendString.data(using: String.Encoding.utf8)!
    }
    
    // Alternativer Versuch zum Entpacken, noch nicht getestet
    func decodeGameState(data : Data) -> GameState {
        var gameState : GameState = GameState()
        let seperator : String = "|"
        let dataAsString : NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        let dataAsStringArray : [String] = dataAsString.components(separatedBy: seperator)
        gameState.gameStatus = dataAsStringArray[0]
        gameState.betNumber[0] = Int(dataAsStringArray[1])!
        gameState.betNumber[1] = Int(dataAsStringArray[2])!
        gameState.setNumber[0] = Int(dataAsStringArray[3])!
        gameState.setNumber[1] = Int(dataAsStringArray[4])!
        gameState.remainingCoins[0] = Int(dataAsStringArray[5])!
        gameState.remainingCoins[1] = Int(dataAsStringArray[6])!
        return gameState
    }
    
    // entnommen aus dem Internet, fragwürdig ob das funktioniert
    func encodeGameState(state: UnsafeRawPointer?) -> NSData {
        return NSData(bytes: state, length: MemoryLayout<GameState>.size)
    }
    
    // entnommen aus dem Internet, fragwürdig ob das funktioniert
    func decodeGameState(nsData: NSData) -> GameState {
        var tempBuffer:GameState? = nil
        nsData.getBytes(&tempBuffer, length: MemoryLayout<GameState>.size)
        if(tempBuffer == nil) {
            print("Tempbuffer ist nil. Fehler beim Dekodieren. Erstelle neuen Gamestate")
            return GameState()
        } else {
            return tempBuffer!
        }
    }
    
    //func exchangeTest(someInteger: Int) -> Int {
    var exchange : [GKTurnBasedExchange]? { get}
    //}
    
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, playerQuitFor match: GKTurnBasedMatch) {
        print("[" + String(describing: self) + "]" + "Match wurde beendet durch Player Quit")
        match.endMatchInTurn(withMatch: encodeGameState(gameState: gameState), completionHandler: nil)
    }
    
    // Temporäre Funktion um Matches vom GameCenter zu löschen, noch nicht getestet
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
                    participant.matchOutcome = GKTurnBasedMatchOutcome.quit  }
                match.endMatchInTurn(withMatch: self.encodeGameState(gameState: self.gameState), completionHandler: {(error: Error?) -> Void in
                    print("Error in endMatch")
                    print(error as Any)
                })
                match.remove(completionHandler: {(error: Error?) -> Void in
                    print("Error in removeGame")
                    print(error as Any)
                })
            }
        })
    }
    
    func setMatchOutcome()
    {
        print("Versuche Match Outcomes zu setzen")
        print("Match Outcome setzen")
        for participant in localMatch.participants! {
            participant.matchOutcome = GKTurnBasedMatchOutcome.none
            if(participant.player?.playerID == GKLocalPlayer.localPlayer().playerID && self.gameState.remainingCoins[(localMatch.participants?.index(of: participant))!] == 0) {
                participant.matchOutcome = GKTurnBasedMatchOutcome.won
                localMatch.endMatchInTurn(withMatch: encodeGameState(gameState: gameState), completionHandler: {(error: Error?) -> Void in
                    print("Error in endMatch")
                    print(error as Any)
                })
            }
        }
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
                sceneNode.initMyLabels()
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
