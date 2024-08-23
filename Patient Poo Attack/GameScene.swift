//
//  GameScene.swift
//  Patient Poo Attack
//
//  Created by Benjamin Couch on 21/8/2024.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0
    var gameStarted = false
    var gameOver = false
    
    let birdCategory: UInt32 = 0x1 << 0
    let pipeCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2
    let bulletCategory: UInt32 = 0x1 << 3
    
    var bullets: [SKSpriteNode] = []

    override func didMove(to view: SKView) {
        setupPhysics()
        createBackground()
        createBird()
        createGround()
        createScoreLabel()
        startGame()
    }

    func setupPhysics() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        self.physicsWorld.contactDelegate = self
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "ground2")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.size = self.size
        background.zPosition = -10
        self.addChild(background)
    }
    
    func createBird() {
        let birdTexture = SKTexture(imageNamed: "patient")
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = pipeCategory | groundCategory
        bird.physicsBody?.collisionBitMask = groundCategory
        bird.physicsBody?.allowsRotation = false
        self.addChild(bird)
    }
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        let ground = SKSpriteNode(texture: groundTexture)
        ground.position = CGPoint(x: self.frame.midX, y: groundTexture.size().height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = birdCategory
        self.addChild(ground)
    }
    
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height - 100)
        scoreLabel.fontSize = 45
        scoreLabel.text = "Score: \(score)"
        self.addChild(scoreLabel)
    }
    
    func updateScore(by points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }
    
    func startGame() {
        gameStarted = true
        let spawn = SKAction.run { [unowned self] in self.createPipes() }
        let delay = SKAction.wait(forDuration: 2.0)
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnForever)
    }
    
    func createPipes() {
        let pipeTexture = SKTexture(imageNamed: "nurse2")
        let pipePair = SKNode()
        pipePair.position = CGPoint(x: self.frame.width + pipeTexture.size().width, y: 0)
        pipePair.zPosition = 5 // Ensure pipes are in front of the background
        
        let pipeHeight = pipeTexture.size().height
        let gapHeight: CGFloat = 150.0 // Adjust this to set the gap between the pipes
        
        // Random position for the gap between the pipes
        let maxY = self.frame.height / 2 + gapHeight / 2
        let minY = -self.frame.height / 2 + gapHeight / 2
        let yPosition = CGFloat.random(in: minY...maxY)
        
        // Pipe Down (top pipe)
        let pipeDown = SKSpriteNode(texture: pipeTexture)
        pipeDown.position = CGPoint(x: 0, y: yPosition + pipeHeight + gapHeight)
        pipeDown.zRotation = .pi // Rotate pipeDown to face downwards
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.physicsBody?.categoryBitMask = pipeCategory
        pipeDown.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeDown)
        
        // Pipe Up (bottom pipe)
        let pipeUp = SKSpriteNode(texture: pipeTexture)
        pipeUp.position = CGPoint(x: 0, y: yPosition)
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        pipeUp.physicsBody?.isDynamic = false
        pipeUp.physicsBody?.categoryBitMask = pipeCategory
        pipeUp.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipeUp)
        
        // Move pipes to the left
        let movePipes = SKAction.moveBy(x: -self.frame.width - pipeTexture.size().width, y: 0, duration: 5.0)
        let removePipes = SKAction.removeFromParent()
        let moveAndRemove = SKAction.sequence([movePipes, removePipes])
        pipePair.run(moveAndRemove)
        
        self.addChild(pipePair)
    }
    
    func resetGame() {
        self.removeAllChildren()
        score = 0
        gameStarted = false
        gameOver = false
        didMove(to: self.view!)
    }
    
    func createBullet() -> SKSpriteNode {
        let bulletTexture = SKTexture(imageNamed: "bullet") // Add your bullet texture
        let bullet = SKSpriteNode(texture: bulletTexture)
        bullet.size = CGSize(width: 10, height: 20) // Adjust size if needed
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = pipeCategory
        bullet.physicsBody?.collisionBitMask = 0
        return bullet
    }

    func shootBullet() {
        let bullet = createBullet()
        bullet.position = CGPoint(x: bird.position.x + 20, y: bird.position.y)
        self.addChild(bullet)
        bullets.append(bullet)
        
        let moveAction = SKAction.moveBy(x: self.frame.size.width, y: 0, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        let moveAndRemoveAction = SKAction.sequence([moveAction, removeAction])
        bullet.run(moveAndRemoveAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver {
            resetGame()
        } else if !gameStarted {
            startGame()
        } else {
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
            shootBullet()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        for bullet in bullets {
            bullet.position.x += 5 // Adjust speed if needed
            if bullet.position.x > self.frame.width {
                bullet.removeFromParent()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == (bulletCategory | pipeCategory) {
            let bullet = contact.bodyA.categoryBitMask == bulletCategory ? contact.bodyA.node : contact.bodyB.node
            let pipe = contact.bodyA.categoryBitMask == pipeCategory ? contact.bodyA.node : contact.bodyB.node
            
            bullet?.removeFromParent()
            pipe?.removeFromParent()
            
            updateScore(by: 10) // Increase score by 10 when a nurse is hit
        } else if !gameOver {
            if contact.bodyA.categoryBitMask == pipeCategory || contact.bodyB.categoryBitMask == pipeCategory ||
                contact.bodyA.categoryBitMask == groundCategory || contact.bodyB.categoryBitMask == groundCategory {
                gameOver = true
                self.removeAllActions()
                bird.physicsBody?.isDynamic = false
                let wait = SKAction.wait(forDuration: 1)
                let reset = SKAction.run { [unowned self] in self.resetGame() }
                let sequence = SKAction.sequence([wait, reset])
                self.run(sequence)
            }
        }
    }
}

