//
//  GameScene.swift
//  Battle of the Stereotypes
//
//  Created by student on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation
import UIKit
import _SwiftUIKitOverlayShims

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Zeigt an wer dran ist und was man tun soll
    var statusLabel: SKLabelNode!
    // Zeigt an wieviel Münzen man hat
    var coinLabel : SKLabelNode!
    // Zeigt die Zahlen an
    var label1 : SKLabelNode!
    var label2 : SKLabelNode!
    var label3 : SKLabelNode!
    // Label zum Zug abgeben
    var labelChangeTurn : SKLabelNode!
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var viewController : GameViewController!
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var leftDummy: SKSpriteNode!
    var rightDummy: SKSpriteNode!
    var arrow: SKSpriteNode!
    var allowsRotation:Bool = true
    
    var angleForArrow:CGFloat! = 0.0
    var angleForArrow2:CGFloat! = 0.0
    
    var adjustedArrow = false
    
    //Wurfgeschoss
    var ball: SKSpriteNode!
    
    //Fire Button zum Einstellen der Kraft beim Wurf
    var fireButton: SKSpriteNode!
    
    //Boden des Spiels
    var ground: SKSpriteNode!
    
    //Kraftbalken
    var powerBar = SKSpriteNode()
    var counter: Int = 0
    var buttonTimer = Timer()
    var TextureAtlas = SKTextureAtlas()
    var TextureArray = [SKTexture]()
    
    //Hintergrund
    var background: SKSpriteNode!
    
    var fired = true
    
    var leftDummyHealthLabel:SKLabelNode!
    var leftDummyHealth:Int = 0 {
        didSet {
            leftDummyHealthLabel.text = "Health: \(leftDummyHealth)/100"
        }
    }
    
    var rightDummyHealthLabel:SKLabelNode!
    var rightDummyHealth:Int = 0 {
        didSet {
            rightDummyHealthLabel.text = "Health: \(rightDummyHealth)/100"
        }
    }
    
    let dummyCategory:UInt32 = 0x1 << 1
    let weaponCategory:UInt32 = 0x1 << 0
    
    //let MaxHealth = 100
    let HealthBarWidth: CGFloat = 240
    let HealthBarHeight: CGFloat = 40
    
    let leftDummyHealthBar = SKSpriteNode()
    let rightDummyHealthBar = SKSpriteNode()
    
    var playerHP = 100
    
    func initMyLabels()
    {
        // Testspiel Labels
        // Statustext
        statusLabel = SKLabelNode(text: "Spieler: DU, setze Münzen!")
        statusLabel.position = CGPoint(x: self.frame.midX, y: rightDummy.frame.midY - 25)
        statusLabel.fontName = "Americantypewriter-Bold"
        statusLabel.color = UIColor.red
        statusLabel.fontSize = 26
        statusLabel.zPosition=3
        self.addChild(statusLabel)
        
        // Münzlabel
        coinLabel = SKLabelNode(text: "Verbleibende Münzen: " + String(viewController.remainingCoins))
        coinLabel.position = CGPoint(x: self.frame.midX, y: rightDummy.frame.midY)
        coinLabel.fontName = "Americantypewriter-Bold"
        coinLabel.color = UIColor.red
        coinLabel.fontSize = 26
        coinLabel.zPosition=3
        self.addChild(coinLabel)
        
        // Münzlabel
        labelChangeTurn = SKLabelNode(text: "Zug abgeben an anderen Spieler")
        labelChangeTurn.position = CGPoint(x: self.frame.midX, y: rightDummy.frame.midY + 135)
        labelChangeTurn.fontName = "Americantypewriter-Bold"
        labelChangeTurn.color = UIColor.red
        labelChangeTurn.fontSize = 26
        labelChangeTurn.zPosition=3
        self.addChild(labelChangeTurn)
        
        // Zahl 1
        label1 = SKLabelNode(text: "1")
        label1.position = CGPoint(x: self.frame.midX + 230, y: rightDummy.frame.midY - 20)
        label1.fontName = "Americantypewriter-Bold"
        label1.color = UIColor.red
        label1.fontSize = 26
        label1.zPosition=3
        self.addChild(label1)
        
        // Zahl 2
        label2 = SKLabelNode(text: "2")
        label2.position = CGPoint(x: self.frame.midX + 230, y: rightDummy.frame.midY + 20)
        label2.fontName = "Americantypewriter-Bold"
        label2.color = UIColor.red
        label2.fontSize = 26
        label2.zPosition=3
        self.addChild(label2)
        
        // Zahl 3
        label3 = SKLabelNode(text: "3")
        label3.position = CGPoint(x: self.frame.midX + 230, y: rightDummy.frame.midY + 60)
        label3.fontName = "Americantypewriter-Bold"
        label3.color = UIColor.red
        label3.fontSize = 26
        label3.zPosition=3
        self.addChild(label3)
    }
    
    override func didMove(to view: SKView) {
        //initialisiere den Boden
        let groundTexture = SKTexture(imageNamed: "Boden")
        ground = SKSpriteNode(texture: groundTexture)
        ground.size = CGSize(width: self.size.width, height: self.size.height/3)
        ground.position.y -= 60
        
        self.addChild(ground)
        
        //initialisiere den Hintergrund
        background = SKSpriteNode(imageNamed: "Hintergrund")
        background.size = CGSize(width: self.size.width, height: self.size.height/3)
        background.anchorPoint=CGPoint(x: 0.5, y: 0.5)
        background.position=CGPoint(x: 0, y: -60)
        background.zPosition = 1
        
        self.addChild(background)
        
        let leftDummyTexture = SKTexture(imageNamed: "dummy")
        leftDummy = SKSpriteNode(texture: leftDummyTexture)
        leftDummy.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 - 250)
        
        leftDummy.physicsBody = SKPhysicsBody(texture: leftDummyTexture, size: leftDummy.size)
        leftDummy.physicsBody?.isDynamic = true
        leftDummy.physicsBody?.affectedByGravity = false
        leftDummy.physicsBody?.categoryBitMask = dummyCategory
        leftDummy.physicsBody?.contactTestBitMask = weaponCategory
        leftDummy.physicsBody?.collisionBitMask = 0
        leftDummy.zPosition=3
        
        self.addChild(leftDummy)
        
        let rightDummyTexture = SKTexture(imageNamed: "dummy")
        rightDummy = SKSpriteNode(texture: leftDummyTexture)
        rightDummy.position = CGPoint(x: self.frame.size.width / 2 - 100, y: rightDummy.size.height / 2 - 250)
        
        rightDummy.physicsBody = SKPhysicsBody(texture: rightDummyTexture,size: rightDummy.size)
        rightDummy.physicsBody?.affectedByGravity = false
        rightDummy.physicsBody?.isDynamic = true
        
        rightDummy.physicsBody?.categoryBitMask = dummyCategory
        rightDummy.physicsBody?.contactTestBitMask = weaponCategory
        rightDummy.physicsBody?.collisionBitMask = 0
        rightDummy.zPosition=3
        
        self.addChild(rightDummy)
        
        leftDummyHealthLabel = SKLabelNode(text: "Health: 100")
        leftDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 630, y: leftDummy.size.height / 2 + 50)
        leftDummyHealthLabel.fontName = "Americantypewriter-Bold"
        leftDummyHealthLabel.fontSize = 26
        leftDummyHealthLabel.fontColor = UIColor.white
        leftDummyHealthLabel.zPosition=3
        leftDummyHealth = 100
        
        self.addChild(leftDummyHealthLabel)
        
        rightDummyHealthLabel = SKLabelNode(text: "Health: 100")
        rightDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 135, y: rightDummy.size.height / 2 + 50)
        rightDummyHealthLabel.fontName = "Americantypewriter-Bold"
        rightDummyHealthLabel.fontSize = 26
        rightDummyHealthLabel.fontColor = UIColor.white
        rightDummyHealthLabel.zPosition=3
        rightDummyHealth = 100
        
        self.addChild(rightDummyHealthLabel)
        leftDummy.name = "leftdummy"
        rightDummy.name = "rightdummy"
        
        //self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //initialisiere das Wurfgeschoss
        let ballTexture = SKTexture(imageNamed: "Krug")
        ball = SKSpriteNode(texture: ballTexture)
        ball.size = CGSize(width: 30, height: 30)
        ball.position = leftDummy.position
        ball.position.x += 30
        ball.physicsBody = SKPhysicsBody(texture: ballTexture, size: ball.size)
        ball.zPosition=3
        ball.physicsBody?.mass = 1
        ball.physicsBody?.allowsRotation=false
        ball.physicsBody?.isDynamic=false
        ball.physicsBody?.affectedByGravity=false
        ball.physicsBody?.collisionBitMask=0x1 << 2
        
        self.addChild(ball)
        
        //initialisiere den Fire Button
        fireButton = SKSpriteNode(imageNamed: "fireButton")
        fireButton.size = CGSize(width: 80, height: 80)
        fireButton.position = CGPoint(x: 0, y: 160)
        fireButton.zPosition=3
        
        self.addChild(fireButton)
        
        //Initialisiere den Kraftbalken
        TextureAtlas = SKTextureAtlas(named: "powerBarImages")
        for i in 0...TextureAtlas.textureNames.count - 1 {
            let name = "progress_\(i)"
            TextureArray.append(SKTexture(imageNamed: name))
        }
        powerBar = SKSpriteNode(imageNamed: "progress_0")
        powerBar.size = CGSize(width: 300, height: 50)
        powerBar.position = CGPoint(x: 0, y: 250 )
        powerBar.zPosition = 3
        self.addChild(powerBar)
        
        initHealthBar()
    }
    
    func initHealthBar(){
        self.addChild(leftDummyHealthBar)
        self.addChild(rightDummyHealthBar)
        
        leftDummyHealthBar.position = CGPoint(
            x: leftDummyHealthLabel.position.x + 7,
            y: leftDummyHealthLabel.position.y + 10
        )
        rightDummyHealthBar.position = CGPoint(
            x: rightDummyHealthLabel.position.x,
            y: rightDummyHealthLabel.position.y + 10
        )
        
        updateHealthBar(node: leftDummyHealthBar, withHealthPoints: playerHP)
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: playerHP)
    }
    
    //Wurf des Projektils
    func throwProjectile() {
        if childNode(withName: "arrow") != nil {
            ball.physicsBody?.affectedByGravity=true
            ball.physicsBody?.isDynamic=true
            ball.physicsBody?.allowsRotation=true
            //Berechnung des Winkels
            let winkel = ((Double.pi/2) * Double(angleForArrow2) / 1.5)
            let xImpulse = cos(winkel)
            let yImpulse = sqrt(1-pow(xImpulse, 2))
            ball.physicsBody?.applyImpulse(CGVector(dx: xImpulse*1000, dy: yImpulse*1000))
            ball.physicsBody?.categoryBitMask = weaponCategory
            ball.physicsBody?.contactTestBitMask = dummyCategory
            ball.physicsBody?.collisionBitMask = 0
            ball.physicsBody?.usesPreciseCollisionDetection = true
            arrow.removeFromParent()
            allowsRotation = true
        }
    }
    
    @objc func timerCallback(){
        if counter < 10 {
            counter += 1
        }
    }
    
    func updateTextLabels()
    {
        var temp = ""
        coinLabel.text = "Verbleibende Münzen: " + String(viewController.remainingCoins)
        if(viewController.islocalPlayersTurn()) {
            temp = "Spieler: DU,"
        } else {
            temp = "Spieler: Gegner,"
        }
        if(viewController.gameStatus == "setzen") {
            statusLabel.text = temp + "setze Münzen!"
        } else {
            statusLabel.text = temp + "rate wieviel Münzen im Spiel sind!"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        if touchedNode.name == "leftdummy" && (childNode(withName: "arrow") == nil)
        {
            createArrow()
        }
        else if touchedNode.name == "rightdummy" && (childNode(withName: "arrow") == nil){
            createArrowRight()
        }
        
        
        //Button drücken, aber nur wenn Pfeil eingestellt
        if adjustedArrow==true{
            if childNode(withName: "arrow") != nil {
                if fireButton.contains(touch.location(in: self)) {
                    powerBar.run(SKAction.animate(with: TextureArray, timePerFrame: 0.2), withKey: "powerBarAction")
                    counter = 0
                    buttonTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerCallback), userInfo: nil, repeats: true)
                    allowsRotation = true
                    
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        if childNode(withName: "arrow") != nil {
            allowsRotation = false
            adjustedArrow = true
            
        }
        if fireButton.contains(touch.location(in: self)) {
            buttonTimer.invalidate()
            powerBar.removeAction(forKey: "powerBarAction")
            throwProjectile()
        }
        
        if(viewController.islocalPlayersTurn() && label1.contains(touch.location(in: self))) {
            if(viewController.gameStatus == "raten") {
                viewController.betNumber = 1
            } else {
                viewController.setNumber = 1
            }
            setNumberLabelsToRed()
            label1.fontColor = UIColor.yellow
        }
        if(viewController.islocalPlayersTurn() && label2.contains(touch.location(in: self))) {
            if(viewController.gameStatus == "raten") {
                viewController.betNumber = 2
            } else {
                viewController.setNumber = 2
            }
            setNumberLabelsToRed()
            label2.fontColor = UIColor.yellow
        }
        if(viewController.islocalPlayersTurn() && label3.contains(touch.location(in: self))) {
            
            if(viewController.gameStatus == "raten") {
                viewController.betNumber = 3
            } else {
                viewController.setNumber = 3
            }
            setNumberLabelsToRed()
            label1.fontColor = UIColor.yellow
        }
        if(viewController.islocalPlayersTurn() && labelChangeTurn.contains(touch.location(in: self))) {
            if(viewController.betNumber == -1 && viewController.gameStatus == "raten") {
                return
            }
            if(viewController.setNumber == -1 && viewController.gameStatus == "setzen") {
                return
            }
            viewController.setMatchOutcome()
            viewController.turnEnded()
        }
    }
    
    func setNumberLabelsToRed()
    {
        label1.fontColor = UIColor.red
        label2.fontColor = UIColor.red
        label3.fontColor = UIColor.red
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let sprite = childNode(withName: "arrow") {
            if(allowsRotation == true){
                let touch:UITouch = touches.first!
                let pos = touch.location(in: self)
                
                _ = self.atPoint(pos)
                let touchedNode = self.atPoint(pos)
                
                let deltaX = self.arrow.position.x - pos.x
                let deltaY = self.arrow.position.y - pos.y
                
                if(touchedNode.name == "leftdummy"){
                    angleForArrow = atan2(deltaX, deltaY)
                    angleForArrow = angleForArrow * -1
                    if(0.0 <= angleForArrow + CGFloat(90 * (Double.pi/180)) && 1.5 >= angleForArrow + CGFloat(90 * (Double.pi/180))){
                        
                        sprite.zRotation = angleForArrow + CGFloat(90 * (Double.pi/180))
                        angleForArrow2 = angleForArrow + CGFloat(90 * (Double.pi/180))
                        
                    }
                }
                else if(touchedNode.name == "rightdummy"){
                    angleForArrow = atan2(deltaY, deltaX)
                    if(3.0 < angleForArrow + CGFloat(90 * (Double.pi/180)) && 4.5 > angleForArrow + CGFloat(90 * (Double.pi/180))){
                        sprite.zRotation = (angleForArrow + CGFloat(Double.pi/2)) + CGFloat(90 * (Double.pi/180))
                    }
                }
                
            }
        }
        
    }
    
    func createArrow(){
        arrow = SKSpriteNode(imageNamed: "pfeil")
        let centerLeft = leftDummy.position
        arrow.position = CGPoint(x: centerLeft.x, y: centerLeft.y)
        arrow.anchorPoint = CGPoint(x:0.0,y:0.5)
        arrow.setScale(0.05)
        arrow.zPosition=3
        self.addChild(arrow)
        arrow.name = "arrow"
    }
    func createArrowRight(){
        arrow = SKSpriteNode(imageNamed: "pfeil")
        let centerLeft = rightDummy.position
        arrow.position = CGPoint(x: centerLeft.x, y: centerLeft.y)
        arrow.anchorPoint = CGPoint(x:0.0,y:0.5)
        arrow.setScale(0.05)
        arrow.zPosition=3
        self.addChild(arrow)
        arrow.xScale = arrow.xScale * -1;
        arrow.name = "arrow"
        
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if (firstBody.categoryBitMask & weaponCategory) != 0 && (secondBody.categoryBitMask & dummyCategory) != 0 && fired == true{
            fired = false
            projectileDidCollideWithDummy(projectileNode: firstBody.node as! SKSpriteNode, dummyNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    func projectileDidCollideWithDummy (projectileNode:SKSpriteNode, dummyNode:SKSpriteNode) {
        //ball.removeFromParent()
        rightDummyHealth -= 50
        updateHealthBar(node: rightDummyHealthBar, withHealthPoints: rightDummyHealth)
        if rightDummyHealth < 0 {
            rightDummyHealth = 0
        }
    }
    
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        let barSize = CGSize(width: HealthBarWidth, height: HealthBarHeight);
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(100)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context!.fill(barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage!)
        node.size = barSize
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
