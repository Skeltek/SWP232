//
//  GameScene.swift
//  Battle of the Stereotypes
//
//  Created by student on 16.04.18.
//  Copyright © 2018 Simongotnews. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var leftDummy: SKSpriteNode!
    var rightDummy: SKSpriteNode!
    var arrow: SKSpriteNode!
    var allowsRotation:Bool = true
    
    var adjustedArrow = false
    
    //Wurfgeschoss
    var ball: SKSpriteNode!
    
    //Fire Button zum Einstellen der Kraft beim Wurf
    var fireButton: SKSpriteNode!
    
    //Boden des Spiels
    var ground: SKSpriteNode!
    
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
        rightDummyHealthLabel.position = CGPoint(x: self.frame.size.width / 2 - 120, y: rightDummy.size.height / 2 + 50)
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
    }
    
    func throwProjectile() {
        ball.physicsBody?.affectedByGravity=true
        ball.physicsBody?.isDynamic=true
        ball.physicsBody?.allowsRotation=true
        ball.physicsBody?.applyImpulse(CGVector(dx: 600, dy: 600))
        ball.physicsBody?.categoryBitMask = weaponCategory
        ball.physicsBody?.contactTestBitMask = dummyCategory
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.usesPreciseCollisionDetection = true
        if childNode(withName: "arrow") != nil{
            arrow.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let pos = touch.location(in: self)
        let touchedNode = self.atPoint(pos)
        if touchedNode.name != nil && (childNode(withName: "arrow") == nil)
        {
                createArrow()
        }
        
        //Button drücken, aber nur wenn Pfeil eingestellt
        if adjustedArrow==true{
            if fireButton.contains(touch.location(in: self)) {
                throwProjectile()
                allowsRotation = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if childNode(withName: "arrow") != nil {
            allowsRotation = false;
            adjustedArrow=true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let sprite = childNode(withName: "arrow") {
            if(allowsRotation == true){
            let touch:UITouch = touches.first!
            let pos = touch.location(in: self)
            
            _ = self.atPoint(pos)
            
            let deltaX = self.arrow.position.x - pos.x
            let deltaY = self.arrow.position.y - pos.y
            
            var angle = atan2(deltaX, deltaY)
            angle = angle * -1
            if(0.0 < angle + CGFloat(90 * (Double.pi/180)) && 1.6 > angle + CGFloat(90 * (Double.pi/180))){
                sprite.zRotation = angle + CGFloat(90 * (Double.pi/180))
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
        rightDummyHealth -= 10
        if rightDummyHealth < 0 {
            rightDummyHealth = 0
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
