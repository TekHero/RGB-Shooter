//
//  GameScene.swift
//  Color Wars - Shooter
//
//  Created by Brian Lim on 3/20/16.
//  Copyright (c) 2016 codebluapps. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode?
    var enemy: SKSpriteNode?
    var laser: SKSpriteNode?
    var leftLaser: SKSpriteNode?
    var rightLaser: SKSpriteNode?
    
    var scoreMultiplier: SKSpriteNode?
    var scoreMultiplierTwo: SKSpriteNode?
    var scoreMultiplierThree: SKSpriteNode?
    var rapidFirePowerup: SKSpriteNode?
    var shieldPowerup: SKSpriteNode?
    var doublePointsPowerup: SKSpriteNode?
    var tripleFirePowerup: SKSpriteNode?
    
    var scoreLbl: SKLabelNode?
    var mainLbl: SKLabelNode?
    
    var fireProjectileRate = 0.1
    var projectileSpeed = 0.8 // 1.4
    
    var laserWidth = 5
    var laserHeight = 15
    
    var enemySpeed = 1.5 // 2.0
    var enemySpawnRate = 0.08 // 0.09
    
    var scorePowerupSpeed = 1.2
    var scorePowerupSpawnRate = 0.08
    
    var rapidFirePowerupSpeed = 0.5
    
    var isAlive = true
    var isRapidFireActive = false
    var isInvincibilityActive = false
    var isDoublePointsActive = false
    var isTripleFireActive = false
    
    var meteorCounter = 0
    
    var score = 0
    var modifiedScore = 1000
    var modifiedScore2 = 25000
    
    var backgroundImg = SKSpriteNode(imageNamed: "SpaceBackground3")
    let backgroundVelocity: CGFloat = 4.0
    
    struct physicsCategory {
        
        static let player: UInt32 = 1
        static let enemy: UInt32 = 2
        static let laser: UInt32 = 3
        static let scorePowerup: UInt32 = 4
        static let scorePowerup2: UInt32 = 5
        static let scorePowerup3: UInt32 = 6
        static let shield: UInt32 = 7
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        /* Setup your scene here */
        
        do {
            _ = try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, with: .mixWithOthers)
            
        } catch {
            // Didnt work
        }
        
        backgroundImg.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        backgroundImg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundImg.zPosition = -2
        self.addChild(backgroundImg)
        
        self.initializingScrollingBackground()
        
        pauseBeforePlay()
        spawnScoreLbl()
        spawnPlayer()
        spawnMainLbl()
        hideLbl()
        resetVariables()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == scoreLbl && self.scene?.isPaused == false {
                
                self.scene?.isPaused = true
                
            } else if atPoint(location) == scoreLbl && self.scene?.isPaused == true {
                
                self.scene?.isPaused = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let touchLocation = touch.location(in: self)
            
            if isAlive == true && self.scene?.isPaused == false {
                // Everytime a touch is detected, the player node is moved to that location
                player?.position.x = touchLocation.x
                player?.position.y = touchLocation.y
            }
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if isAlive == false {
            player?.position.x = -200
            player?.position.y = -200
        }
        
        self.moveBackground()
        
    }
    
    func initializingScrollingBackground() {
        for index in 0 ..< 3 {
            let bg = SKSpriteNode(imageNamed: "SpaceBackground3")
            bg.position = CGPoint(x: 0, y: index * Int(bg.size.width))
            bg.anchorPoint = CGPoint.zero
            bg.name = "background"
            bg.zPosition = -2
            self.addChild(bg)
        }
    }
    
    func moveBackground() {
        self.enumerateChildNodes(withName: "background", using: { (node, stop) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x, y: bg.position.y - self.backgroundVelocity)
                
                // Checks if bg node is completely scrolled off the screen, if yes, then puts it at the end of the other node.
                if bg.position.y <= -bg.size.height {
                    bg.position = CGPoint(x: bg.position.x , y: bg.position.y + bg.size.height * 2)
                }
            }
        })
    }
    
    func rotateSprite() {
        let rotate = SKAction.rotate(byAngle: 1.5, duration: 0.4)
        enemy?.run(SKAction.repeatForever(rotate))
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "SpaceshipV3")
        player?.size = CGSize(width: 75, height: 75)
        player?.position = CGPoint(x: self.frame.midX, y: 150)
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player?.physicsBody?.isDynamic = false
        player?.name = "Player"
        
        self.addChild(player!)
    }
    
    func spawnEnemy() {
        enemy = SKSpriteNode(imageNamed: "aestroid_grey")
        enemy?.size = CGSize(width: 55, height: 55)
        enemy?.position = CGPoint(x: Int(arc4random_uniform(1000) + 300), y: 800)
        enemy?.physicsBody = SKPhysicsBody(rectangleOf: (enemy?.size)!)
        enemy?.physicsBody?.affectedByGravity = false
        enemy?.physicsBody?.categoryBitMask = physicsCategory.enemy
        enemy?.physicsBody?.contactTestBitMask = physicsCategory.laser
        enemy?.physicsBody?.allowsRotation = false
        enemy?.physicsBody?.isDynamic = true
        enemy?.name = "Meteor"
        rotateSprite()
        
        var moveFowardAction = SKAction.moveTo(y: -100, duration: enemySpeed)
        let destroyAction = SKAction.removeFromParent()
        
        enemy?.run(SKAction.sequence([moveFowardAction, destroyAction]))
        
        if isAlive == false {
            moveFowardAction = SKAction.moveTo(y: 2000, duration: 1.0)
        }
        
        self.addChild(enemy!)
    }
    
    func spawnLasers() {
        laser = SKSpriteNode(color: getRandomColor(), size: CGSize(width: laserWidth, height: laserHeight))
        laser?.position = CGPoint(x: (player?.position.x)!, y: (player?.position.y)!)
        laser?.physicsBody?.affectedByGravity = false
        laser?.physicsBody = SKPhysicsBody(rectangleOf: laser!.size)
        laser?.physicsBody?.categoryBitMask = physicsCategory.laser
        laser?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        laser?.physicsBody?.isDynamic = false
        laser?.zPosition = -1
        laser?.name = "Laser"
        
        let moveFowardAction = SKAction.moveTo(y: 900, duration: projectileSpeed)
        let destroyAction = SKAction.removeFromParent()
        
        laser?.run(SKAction.sequence([moveFowardAction, destroyAction]))
        
        self.addChild(laser!)
        playLaserSound()
    
    }
    
    func spawnLeftLasers() {
        leftLaser = SKSpriteNode(color: getRandomColor(), size: CGSize(width: laserWidth, height: laserHeight))
        leftLaser?.position = CGPoint(x: ((player?.position.x)! - 12), y: (player?.position.y)!)
        leftLaser?.physicsBody?.affectedByGravity = false
        leftLaser?.physicsBody?.isDynamic = false
        leftLaser?.physicsBody = SKPhysicsBody(rectangleOf: (leftLaser?.size)!)
        leftLaser?.zPosition = -1
        leftLaser?.name = "Laser"
        
        let moveUpAction = SKAction.moveTo(y: 900, duration: projectileSpeed)
        let destroyAction = SKAction.removeFromParent()
        
        leftLaser?.run(SKAction.sequence([moveUpAction, destroyAction]))
        
        self.addChild(leftLaser!)
    }
    
    func spawnRightLasers() {
        rightLaser = SKSpriteNode(color: getRandomColor(), size: CGSize(width: laserWidth, height: laserHeight))
        rightLaser?.position = CGPoint(x: ((player?.position.x)! + 12), y: (player?.position.y)!)
        rightLaser?.physicsBody?.affectedByGravity = false
        rightLaser?.physicsBody?.isDynamic = false
        rightLaser?.physicsBody = SKPhysicsBody(rectangleOf: (leftLaser?.size)!)
        rightLaser?.zPosition = -1
        rightLaser?.name = "Laser"
        
        let moveUpAction = SKAction.moveTo(y: 900, duration: projectileSpeed)
        let destroyAction = SKAction.removeFromParent()
        
        rightLaser?.run(SKAction.sequence([moveUpAction, destroyAction]))
        
        self.addChild(rightLaser!)
    }
    
    func spawnScoreMultiplierPowerup() {
        scoreMultiplier = SKSpriteNode(imageNamed: "PurpleMeteor")
        scoreMultiplier?.size = CGSize(width: 40, height: 40)
        scoreMultiplier?.position = CGPoint(x: CGFloat(arc4random_uniform(700) + 200), y: 1000)
        scoreMultiplier?.physicsBody = SKPhysicsBody(rectangleOf: scoreMultiplier!.size)
        scoreMultiplier?.physicsBody?.affectedByGravity = false
        scoreMultiplier?.physicsBody?.categoryBitMask = physicsCategory.scorePowerup
        scoreMultiplier?.physicsBody?.contactTestBitMask = physicsCategory.player
        scoreMultiplier?.physicsBody?.isDynamic = true
        scoreMultiplier?.physicsBody?.allowsRotation = false
        scoreMultiplier?.name = "ScoreMultiplier"
        
        var moveFowardAction = SKAction.moveTo(y: -100, duration: scorePowerupSpeed)
        let destroy = SKAction.removeFromParent()
        
        scoreMultiplier?.run(SKAction.sequence([moveFowardAction, destroy]))
        
        if isAlive == false {
            moveFowardAction = SKAction.moveTo(y: 2000, duration: 1.0)
        }
        
        self.addChild(scoreMultiplier!)
    }
    
    func spawnScoreMultiplierPowerupTwo() {
        scoreMultiplierTwo = SKSpriteNode(imageNamed: "OrangeMeteor")
        scoreMultiplierTwo?.size = CGSize(width: 40, height: 40)
        scoreMultiplierTwo?.position = CGPoint(x: 0, y: CGFloat(arc4random_uniform(900) + 400))
        scoreMultiplierTwo?.physicsBody = SKPhysicsBody(rectangleOf: (scoreMultiplierTwo?.size)!)
        scoreMultiplierTwo?.physicsBody?.affectedByGravity = false
        scoreMultiplierTwo?.physicsBody?.categoryBitMask = physicsCategory.scorePowerup2
        scoreMultiplierTwo?.physicsBody?.contactTestBitMask = physicsCategory.laser
        scoreMultiplierTwo?.physicsBody?.allowsRotation = false
        scoreMultiplierTwo?.physicsBody?.isDynamic = true
        scoreMultiplierTwo?.name = "ScoreMultiplierTwo"
        
        var moveRightAction = SKAction.moveTo(x: 1000, duration: 1.0)
        let destroy = SKAction.removeFromParent()
        
        scoreMultiplierTwo?.run(SKAction.sequence([moveRightAction, destroy]))
        
        if isAlive == false {
            moveRightAction = SKAction.moveTo(x: -2000, duration: 1.0)
        }
        
        self.addChild(scoreMultiplierTwo!)
    }
    
    func spawnScoreMultiplierPowerupThree() {
        scoreMultiplierThree = SKSpriteNode(imageNamed: "OrangeMeteor")
        scoreMultiplierThree?.size = CGSize(width: 40, height: 40)
        scoreMultiplierThree?.position = CGPoint(x: 700, y: CGFloat(arc4random_uniform(900) + 400))
        scoreMultiplierThree?.physicsBody = SKPhysicsBody(rectangleOf: (scoreMultiplierTwo?.size)!)
        scoreMultiplierThree?.physicsBody?.affectedByGravity = false
        scoreMultiplierThree?.physicsBody?.categoryBitMask = physicsCategory.scorePowerup3
        scoreMultiplierThree?.physicsBody?.contactTestBitMask = physicsCategory.laser
        scoreMultiplierThree?.physicsBody?.allowsRotation = false
        scoreMultiplierThree?.physicsBody?.isDynamic = true
        scoreMultiplierThree?.name = "ScoreMultiplierThree"
        
        var moveLeftAction = SKAction.moveTo(x: -1000, duration: 1.0)
        let destroy = SKAction.removeFromParent()
        
        scoreMultiplierThree?.run(SKAction.sequence([moveLeftAction, destroy]))
        
        if isAlive == false {
            moveLeftAction = SKAction.moveTo(x: 2000, duration: 1.0)
        }
        
        self.addChild(scoreMultiplierThree!)
    }
    
    func spawnRapidFirePowerup() {
        rapidFirePowerup = SKSpriteNode(imageNamed: "RapidFirePowerupV1")
        rapidFirePowerup?.size = CGSize(width: 40, height: 40)
        rapidFirePowerup?.position = CGPoint(x: 0, y: CGFloat(arc4random_uniform(900) + 400))
        rapidFirePowerup?.physicsBody = SKPhysicsBody(rectangleOf: (rapidFirePowerup?.size)!)
        rapidFirePowerup?.physicsBody?.affectedByGravity = false
        rapidFirePowerup?.physicsBody?.allowsRotation = false
        rapidFirePowerup?.physicsBody?.isDynamic = true
        rapidFirePowerup?.name = "RapidFirePowerup"
        
        var moveRightAction = SKAction.moveTo(x: 1000, duration: rapidFirePowerupSpeed)
        let destroy = SKAction.removeFromParent()
        
        rapidFirePowerup?.run(SKAction.sequence([moveRightAction, destroy]))
        
        if isAlive == false {
            moveRightAction = SKAction.moveTo(y: -2000, duration: 1.0)

        }
        
        self.addChild(rapidFirePowerup!)
    }
    
    func spawnShield() {
        shieldPowerup = SKSpriteNode(imageNamed: "ShieldPowerupV1")
        shieldPowerup?.size = CGSize(width: 40, height: 40)
        shieldPowerup?.position = CGPoint(x: Int(arc4random_uniform(1000) + 300), y: 800)
        shieldPowerup?.physicsBody?.affectedByGravity = false
        shieldPowerup?.physicsBody?.isDynamic = true
        shieldPowerup?.physicsBody?.allowsRotation = false
        shieldPowerup?.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        shieldPowerup?.name = "Shield"
        shieldPowerup?.zPosition = -1
        
        let moveDownAction = SKAction.moveTo(y: -100, duration: 0.7)
        let destroy = SKAction.removeFromParent()
        shieldPowerup?.run(SKAction.sequence([moveDownAction, destroy]))
        
        self.addChild(shieldPowerup!)
    }
    
    func spawnDoublePoints() {
        doublePointsPowerup = SKSpriteNode(imageNamed: "DoublePointsPowerup")
        doublePointsPowerup?.size = CGSize(width: 40, height: 40)
        doublePointsPowerup?.position = CGPoint(x: 700, y: CGFloat(arc4random_uniform(900) + 400))
        doublePointsPowerup?.physicsBody?.affectedByGravity = false
        doublePointsPowerup?.physicsBody?.isDynamic = true
        doublePointsPowerup?.physicsBody?.allowsRotation = false
        doublePointsPowerup?.physicsBody = SKPhysicsBody(rectangleOf: (doublePointsPowerup?.size)!)
        doublePointsPowerup?.name = "Double Points"
        
        let moveLeftAction = SKAction.moveTo(x: -1000, duration: 1.0)
        let destroy = SKAction.removeFromParent()
        doublePointsPowerup?.run(SKAction.sequence([moveLeftAction,destroy]))
        
        self.addChild(doublePointsPowerup!)
    }
    
    func spawnTripleFirePowerup() {
        tripleFirePowerup = SKSpriteNode(imageNamed: "TripleFirePowerupV1")
        tripleFirePowerup?.size = CGSize(width: 40, height: 40)
        tripleFirePowerup?.position = CGPoint(x: 0, y: CGFloat(arc4random_uniform(900) + 400))
        tripleFirePowerup?.physicsBody?.affectedByGravity = false
        tripleFirePowerup?.physicsBody?.isDynamic = true
        tripleFirePowerup?.physicsBody?.allowsRotation = false
        tripleFirePowerup?.physicsBody = SKPhysicsBody(rectangleOf: (tripleFirePowerup?.size)!)
        tripleFirePowerup?.name = "Triple Fire Powerup"
        
        let moveRightAction = SKAction.moveTo(x: 1000, duration: 1.0)
        let destroy = SKAction.removeFromParent()
        tripleFirePowerup?.run(SKAction.sequence([moveRightAction, destroy]))
        
        self.addChild(tripleFirePowerup!)
        
    }
    
    func spawnScoreLbl() {
        scoreLbl = SKLabelNode(fontNamed: "Prototype")
        scoreLbl?.fontSize = 35
        scoreLbl?.alpha = 0.7
        scoreLbl?.fontColor = UIColor.white
        scoreLbl?.position = CGPoint(x: self.frame.midX, y: 720)
        
        self.addChild(scoreLbl!)
    }
    
    func spawnMainLbl() {
        mainLbl = SKLabelNode(fontNamed: "Prototype")
        mainLbl?.fontSize = 50
        mainLbl?.fontColor = UIColor.white
        mainLbl?.position = CGPoint(x: self.frame.midX, y: 500)
        mainLbl?.text = "Start"
        
        self.addChild(mainLbl!)
    }
    
    func spawnExplosion(_ enemyTemp: SKSpriteNode) {
        // let explosionEmitterPath: NSString = NSBundle.mainBundle().pathForResource("Explosion", ofType: "sks")!
        // let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(explosionEmitterPath as String) as! SKEmitterNode
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        
        explosion!.position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        explosion!.zPosition = -1
        explosion!.targetNode = self
        explosion!.particleColorSequence = nil
        explosion!.particleColorBlendFactor = 1.0
        explosion!.particleColor = getRandomColor()
        
        self.addChild(explosion!)
        
        let explosionTimerRemoval = SKAction.wait(forDuration: 0.5)
        let removeExplosion = SKAction.run {
            
            if self.intersects(explosion!) {
                
                explosion!.removeFromParent()
            } else {
                // print("Explosion is not in scene yet")
                explosion!.removeFromParent()
            }
            
        }
        
        self.run(SKAction.sequence([explosionTimerRemoval, removeExplosion]))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Meteor" && nodeB.name == "Laser" || nodeA.name == "Laser" && nodeB.name == "Meteor" {
                
                // Laser collided with meteor
                playSound()
                spawnExplosion(nodeA as! SKSpriteNode)
                spawnExplosion(nodeB as! SKSpriteNode)
                projectileCollision(nodeA as! SKSpriteNode)
                projectileCollision(nodeB as! SKSpriteNode)
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Meteor" && nodeB.name == "Player" || nodeA.name == "Player" && nodeB.name == "Meteor" {
                
                // Player collided with meteor
                if soundOn == true {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                spawnExplosion(nodeA as! SKSpriteNode)
                spawnExplosion(nodeB as! SKSpriteNode)
                playSound()
                enemyPlayerCollision()
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Laser" && nodeB.name == "ScoreMultiplier" || nodeA.name == "ScoreMultiplier" && nodeB.name == "Laser" {
                
                // Laser collided with score powerup1
                scorePowerupCollision1(nodeA as! SKSpriteNode)
                scorePowerupCollision1(nodeB as! SKSpriteNode)
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Laser" && nodeB.name == "ScoreMultiplierTwo" || nodeA.name == "ScoreMultiplierTwo" && nodeB.name == "Laser" {
                
                // Laser collided with score powerup2
                scorePowerupCollision2(nodeA as! SKSpriteNode)
                scorePowerupCollision2(nodeB as! SKSpriteNode)
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Laser" && nodeB.name == "RapidFirePowerup" || nodeA.name == "RapidFirePowerup" && nodeB.name == "Laser" {
                
                // Laser collided with rapid fire powerup
                playSound2()
                rapidFirePowerupCollision()
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Shield" && nodeB.name == "Laser" || nodeA.name == "Laser" && nodeB.name == "Shield" {
                
                // Player got shield powerup
                playSound2()
                invincibilityPowerupCollision()
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Double Points" && nodeB.name == "Laser" || nodeA.name == "Laser" && nodeB.name == "Double Points" {
                
                // Player got double points powerup
                playSound2()
                doublePointsCollision()
            }
        }
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            if nodeA.name == "Triple Fire Powerup" && nodeB.name == "Laser" || nodeA.name == "Laser" && nodeB.name == "Triple Fire Powerup" {
                
                // Player got triple fire powerup
                playSound2()
                tripleFireCollision()
            }
        }
    }
    
    func invincibilityPowerupCollision() {
        
        if isInvincibilityActive == false {
            
            isInvincibilityActive = true
            self.shieldPowerup?.removeFromParent()
            
            self.player?.physicsBody = nil
            updateMainLblTxt("Invincibility Activated")
            mainLbl?.fontSize = 35
            let duration = SKAction.wait(forDuration: 10.0)
            let removePowerup = SKAction.run {
        
                self.updateMainLblTxt("Invincibility Deactivated")
                self.mainLbl?.fontSize = 35
                self.enablePhysicsBody()
                self.isInvincibilityActive = false
            }
            self.run(SKAction.sequence([duration, removePowerup]))
            
        } else {
            self.shieldPowerup?.removeFromParent()
        }
        
    }
    
    func enablePhysicsBody() {
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.enemy
        player?.physicsBody?.isDynamic = false
    }
    
    func updateMainLblTxt(_ text: String) {
        mainLbl?.alpha = 1.0
        mainLbl?.fontSize = 30
        mainLbl?.text = "\(text)"
        hideLbl()
    }
    
    func tripleFireCollision() {
        
        if isTripleFireActive == false {
            
            fireDoubleLaser()
            isTripleFireActive = true

            updateMainLblTxt("Triple Fire Activated")
            
            let duration = SKAction.wait(forDuration: 10.0)
            let removeTripleFire = SKAction.run {

                self.updateMainLblTxt("Triple Fire Deactivated")
                self.isTripleFireActive = false
            }
            
            self.run(SKAction.sequence([duration, removeTripleFire]))
            
        } else {
            
            self.tripleFirePowerup?.removeFromParent()
        }
    }
    
    func doublePointsCollision() {
        
        if isDoublePointsActive == false {
            
            isDoublePointsActive = true

            updateMainLblTxt("Double Points Activated")
            let duration = SKAction.wait(forDuration: 20.0)
            let removeDoublePoints = SKAction.run {

                self.updateMainLblTxt("Double Points Deactivated")
                self.isDoublePointsActive = false
            }
            
            self.run(SKAction.sequence([duration, removeDoublePoints]))
            
        } else {
            self.doublePointsPowerup?.removeFromParent()
        }
        
    }
    
    func rapidFirePowerupCollision() {
        
        if isRapidFireActive == false {
            projectileSpeed = 0.5
            laserWidth = 5
            updateMainLblTxt("Rapid Fire Activated")
            isRapidFireActive = true
            
            let duration = SKAction.wait(forDuration: 15.0)
            let removeRapidFire = SKAction.run {
                self.projectileSpeed = 0.8
                self.updateMainLblTxt("Rapid Fire Deactivated")
                self.isRapidFireActive = false
            }
            
            self.run(SKAction.sequence([duration, removeRapidFire]))
            
        } else {
            self.rapidFirePowerup?.removeFromParent()
        }
    }
    
    func projectileCollision(_ enemyTemp: SKSpriteNode) {
        
        if (!intersects(enemyTemp)) {
            // Node is not in the scene yet
        } else {
            enemyTemp.removeFromParent()
        }
        
        meteorCounter = meteorCounter + 1
        
        if isDoublePointsActive == false {
            
            score = score + 1
            updateScore()
            
        } else if isDoublePointsActive == true {
            
            score = score + 2
            updateScore()
        }
        
    }
    
    func enemyPlayerCollision() {
        mainLbl?.alpha = 1.0
        mainLbl?.fontSize = 40
        mainLbl?.text = "GAMEOVER"
        
        _ = UserDefaults.standard.setValue(meteorCounter, forKey: "MeteorCounter")
        
        player?.removeFromParent()
        
        isAlive = false
        
        scoreLbl?.alpha = 0.0
        waitThenMoveToTitleScreen()
    }
    
    func scorePowerupCollision1(_ scorePowerup: SKSpriteNode) {
        
        if (!intersects(scorePowerup)) {
            // Score Powerup is not in scene yet
        } else {
            scorePowerup.removeFromParent()
        }
        
        if isDoublePointsActive == false {
            
            score = score + modifiedScore
            updateScore()
            
        } else if isDoublePointsActive == true {
            
            score = score + modifiedScore * 2
            updateScore()
        }
        
    }
    
    func scorePowerupCollision2(_ scorePowerup: SKSpriteNode) {
        
        if (!intersects(scorePowerup)) {
            // Score Powerup is not in scene yet
        } else {
            scorePowerup.removeFromParent()
        }
        
        if isDoublePointsActive == false {
            
            score = score + modifiedScore2
            updateScore()
            
        } else if isDoublePointsActive == true {
            
            score = score + modifiedScore2 * 2
            updateScore()
        }
        
    }
    
    func waitThenMoveToTitleScreen() {
        let wait = SKAction.wait(forDuration: 3.0)
        let transition = SKAction.run {
            self.view?.presentScene(GameoverScene(), transition: SKTransition.crossFade(withDuration: 0.3))
        }
        
        let sequence = SKAction.sequence([wait, transition])
        UserDefaults.standard.set(score, forKey: "SCORE")
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func fireLaser() {
        let fireLaserTimer = SKAction.wait(forDuration: fireProjectileRate)
        let spawn = SKAction.run {
            self.spawnLasers()
        }
        
        let sequence = SKAction.sequence([fireLaserTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func fireDoubleLaser() {
        let fireLaserTimer = SKAction.wait(forDuration: fireProjectileRate)
        let spawn = SKAction.run {
            
            if self.isTripleFireActive == true {
                
                self.spawnLeftLasers()
                self.spawnRightLasers()
                
            }
            
        }
        
        let sequence = SKAction.sequence([fireLaserTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomEnemyTimerSpawn() {
        let enemySpawnTimer = SKAction.wait(forDuration: enemySpawnRate)
        let spawn = SKAction.run {
            self.spawnEnemy()
        }
        
        let sequence = SKAction.sequence([enemySpawnTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomScorePowerupSpawn() {
        let scorePowerupTimer = SKAction.wait(forDuration: 1.0)
        let spawn = SKAction.run {
            self.spawnScoreMultiplierPowerup()
        }
        
        let sequence = SKAction.sequence([scorePowerupTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomScorePowerupSpawn2() {
        let scorePowerupTimer = SKAction.wait(forDuration: 5.0)
        let spawn = SKAction.run {
            self.spawnScoreMultiplierPowerupTwo()
            self.spawnScoreMultiplierPowerupThree()
        }
        
        let sequence = SKAction.sequence([scorePowerupTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomRapidFirePowerupSpawn() {
        let rapidFireTimer = SKAction.wait(forDuration: 15.0)
        let spawn = SKAction.run {
            
            if self.isRapidFireActive == true {
                // Rapid Fire Powerup is already active
            } else {
                
                self.spawnRapidFirePowerup()
            }
            
        }
        
        let sequence = SKAction.sequence([rapidFireTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomShieldPowerupSpawn() {
        let shieldTimer = SKAction.wait(forDuration: 15.0) // 15.0
        let spawn = SKAction.run {
            
            if self.isInvincibilityActive == false {
                self.spawnShield()
            }
            
        }
        let sequence = SKAction.sequence([shieldTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomDoublePointsSpawn() {
        let doublePointsTimer = SKAction.wait(forDuration: 15.0)
        let spawn = SKAction.run {
            
            if self.isDoublePointsActive == false {
                
                self.spawnDoublePoints()
            }
            
        }
        
        let sequence = SKAction.sequence([doublePointsTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func randomTripleFireSpawn() {
        let tripleFireTimer = SKAction.wait(forDuration: 15.0)
        let spawn = SKAction.run {
            
            if self.isTripleFireActive == false {
                
                self.spawnTripleFirePowerup()
            }
            
        }
        
        let sequence = SKAction.sequence([tripleFireTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    func hideLbl() {
        let wait = SKAction.wait(forDuration: 1.4)
        let hide = SKAction.run {
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
            self.mainLbl?.run(fadeOut)
        }
        
        let sequence = SKAction.sequence([wait, hide])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    
    func resetVariables() {
        isAlive = true
        score = 0
        isDoublePointsActive = false
        isInvincibilityActive = false
        isRapidFireActive = false
        isTripleFireActive = false
        enemySpeed = 1.5
    }
    
    func updateScore() {
        
        if score >= 1000000000 {
            scoreLbl?.text = "\(score)"
        } else if score >= 100000000 {
            scoreLbl?.text = "0\(score)"
        } else if score >= 10000000 {
            scoreLbl?.text = "00\(score)"
        } else if score >= 1000000 {
            scoreLbl?.text = "000\(score)"
        } else if score >= 100000 {
            scoreLbl?.text = "0000\(score)"
        } else if score >= 10000 {
            scoreLbl?.text = "00000\(score)"
        } else if score >= 1000 {
            scoreLbl?.text = "000000\(score)"
        } else if score >= 100 {
            scoreLbl?.text = "0000000\(score)"
        } else if score >= 10 {
            scoreLbl?.text = "00000000\(score)"
        } else if score >= 0 {
            scoreLbl?.text = "000000000\(score)"
        }
    }
    
    func playSound() {
        
        if soundOn == true {
            self.run(SKAction.playSoundFileNamed("ExplosionSound.mp3", waitForCompletion: false))
        }
        
    }
    
    func playSound2() {
        
        if soundOn == true {
            self.run(SKAction.playSoundFileNamed("CorrectSound2.wav", waitForCompletion: false))
            
        }
        
    }
    
    func playLaserSound() {
        
        if soundOn == true {
            
            if isAlive == true {
                
                self.run(SKAction.playSoundFileNamed("LaserSound.mp3", waitForCompletion: false))
            }
            
        }
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func waitBeforeIncreasingSpeedRate2() {
        
        let wait = SKAction.wait(forDuration: 30)
        let changeRate = SKAction.run {
            self.enemySpeed = 1.2
        }
        
        let sequence = SKAction.sequence([wait, changeRate])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func waitBeforeIncreasingSpeedRate() {
        
        let wait = SKAction.wait(forDuration: 30)
        let changeRate = SKAction.run {
            self.enemySpeed = 1.4
            self.waitBeforeIncreasingSpeedRate2()
        }
        
        let sequence = SKAction.sequence([wait, changeRate])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func pauseBeforeSpawningRapidFire() {
        let wait = SKAction.wait(forDuration: 5.0)
        let spawn = SKAction.run {
            self.spawnRapidFirePowerup()
            self.randomRapidFirePowerupSpawn()
            self.pauseBeforeSpawningTripleFire()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeat(sequence, count: 1))
        
    }
    
    func pauseBeforeSpawningInvicibility() {
        let wait = SKAction.wait(forDuration: 5.0) //10.0
        let spawn = SKAction.run {
            self.spawnShield()
            self.randomShieldPowerupSpawn()
            self.waitBeforeIncreasingSpeedRate()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeat(sequence, count: 1))
        
    }
    
    func pauseBeforeSpawningDoublePoints() {
        let wait = SKAction.wait(forDuration: 5.0)
        let spawn = SKAction.run {
            self.spawnDoublePoints()
            self.randomDoublePointsSpawn()
            self.pauseBeforeSpawningRapidFire()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeat(sequence, count: 1))
        
    }
    
    func pauseBeforeSpawningTripleFire() {
        let wait = SKAction.wait(forDuration: 5.0)
        let spawn = SKAction.run {
            self.spawnTripleFirePowerup()
            self.randomTripleFireSpawn()
            self.pauseBeforeSpawningInvicibility()
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeat(sequence, count: 1))
        
    }
    
    func pauseBeforeSpawningPowerups() {
        let wait = SKAction.wait(forDuration: 10.0)
        let spawn = SKAction.run {
            self.spawnScoreMultiplierPowerup()
            self.spawnScoreMultiplierPowerupTwo()
            self.pauseBeforeSpawningDoublePoints()
            
            self.randomScorePowerupSpawn()
            self.randomScorePowerupSpawn2()
            
        }
        
        let sequence = SKAction.sequence([wait, spawn])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func pauseBeforePlay() {
        let wait = SKAction.wait(forDuration: 0.6)
        let play = SKAction.run {
            self.pauseBeforeSpawningPowerups()
            self.spawnEnemy()
            self.spawnLasers()
            self.fireLaser()
            self.randomEnemyTimerSpawn()
            self.updateScore()
        }
        
        let sequence = SKAction.sequence([wait, play])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    
}
