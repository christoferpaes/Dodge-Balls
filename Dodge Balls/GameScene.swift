//
//  GameScene.swift
//  Dodge Balls
//
//  Created by Valentina Carfagno on 5/3/19.
//  Copyright © 2019 RSC. All rights reserved.
//

import SpriteKit
import GameplayKit
import os.log



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player : SKSpriteNode?
    var ball : SKSpriteNode?
    var floor : SKSpriteNode?
    var playerY : CGFloat = 305.0
    var playerX : CGFloat = 0.0
    var floorHeight : CGFloat = 25.0
    var floorMax : CGFloat =  1200.0
    var floorAdjust : CGFloat = 4.0
    
    var btnPausePlay : UIButton!
    
    var statusLabel : SKLabelNode?
    var scoreLabel : SKLabelNode?
    
    var ballSpeed = 1.50 //.8 lower is faster
    var ballTimerSpawn =  0.8 //.5  lower is faster
    
    var isAlive = true
    var gamePaused = false
    
    var score = 0
    
    var labelTextColor = UIColor.white
    var floorColor = UIColor(red: 81/255, green: 38/255, blue:70/255,
                             alpha : 1.0)
    
    var touchLocation : CGPoint?
    
    struct physicsCategory {
        static let player : UInt32 = 1
        static let ball : UInt32 = 32
        
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self as SKPhysicsContactDelegate
        
        
        self.backgroundColor = UIColor.lightGray
        spawnPlayer()
        spawnFloor()
        spawnPausePlayButton()
  ballSpawnTimer()
      spawnStatusLabel()
  spawnScoreLabel()
        hideStatusLabel()
        resetVariableOnStart()
        addToScore()
   
    }
    func didBegin(_ contact: SKPhysicsContact){
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == physicsCategory.player)) &&
        (secondBody.categoryBitMask == physicsCategory.ball)
        
        {
            ballUnwinding()
            spawnSmoke(playerTemp: firstBody.node as! SKSpriteNode)
            ballCollision(playerTemp: firstBody.node as! SKSpriteNode, ballTemp:
            secondBody.node as! SKSpriteNode)
            
        }
        
        if (( firstBody.categoryBitMask == physicsCategory.ball) &&
            (secondBody.categoryBitMask == physicsCategory.player)){
            ballUnwinding()
            spawnSmoke(playerTemp: secondBody.node as! SKSpriteNode)
            ballCollision(playerTemp: secondBody.node as! SKSpriteNode, ballTemp:
            firstBody.node as! SKSpriteNode)
        }
    }
    func ballUnwinding() {
        // unwind the balls that have been spawned to clear the view
        
        self.enumerateChildNodes(withName: "enemyBall") {
            (node, stop) in
            node.run(SKAction.hide())
            if let name = node.name, name.contains("enemyBall") {
                stop.initialize(to: true)
            }
            if let sprite = node as? SKSpriteNode {
                sprite.removeFromParent()
            }
        }
    }
    func ballCollision(playerTemp: SKSpriteNode, ballTemp: SKSpriteNode) {
        ballTemp.removeFromParent()
        playerTemp.removeFromParent()
        statusLabel?.alpha = 1.0
        statusLabel?.fontSize = 90
        statusLabel?.fontSize = 50
        if score > highScore {
            highScore = score
            statusLabel?.text = "NEW high score! \(highScore)"
            statusLabel?.fontColor = scoreLabel?.fontColor
            saveScores()
        }
        else{
            statusLabel?.text = "Game Over, try again"
        }
        
        isAlive = false
        
        waitThenMoveToTitleScene()
        
    }
    @objc func pausePlayTheGame() {
        if isPaused == false {
            ballUnwinding()
            isPaused = true
            btnPausePlay.isHighlighted = true
        } else {
            isPaused = false
            btnPausePlay.isHighlighted = false
            
        }
    }
    func  resetVariableOnStart() {
        score = 0
        isAlive = true
        isPaused = false
        statusLabel?.fontSize = 100
        statusLabel?.fontColor = labelTextColor
        
    }
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "playerCircle")
        player?.size = CGSize(width: 65, height: 65)
        
        // player?.position (CGPoint( x:self.frame.midx, y: self.frame.minY + floorHeight + playerY - 25.0)
        player?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + floorHeight + playerY - 25.0)
        player?.physicsBody = SKPhysicsBody(rectangleOf: (player!.size))
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.isDynamic = false
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.categoryBitMask = physicsCategory.player
        player?.physicsBody?.contactTestBitMask = physicsCategory.ball
  
        
        self.addChild(player!)
        
    }
    func spawnBall() {
        
        ball = SKSpriteNode(imageNamed: "redCircle") // 206, 61 , 46
        ball?.size = CGSize(width: 45, height: 45)
        
        let leftRightRange = leftRightX()
        ball?.position = CGPoint(x: Int(arc4random_uniform(50)) + leftRightRange,
                                 y: 1000)
        ball?.physicsBody = SKPhysicsBody(rectangleOf: (ball!.size))
         ball?.physicsBody?.affectedByGravity = false
         ball?.physicsBody?.isDynamic = true
         ball?.physicsBody?.allowsRotation = false
         ball?.physicsBody?.categoryBitMask = physicsCategory.ball
         ball?.physicsBody?.contactTestBitMask = physicsCategory.player
        ball?.name = "enemyBall"
        var moveForward = SKAction.moveTo(y: self.frame.minY/2-50, duration:
        ballSpeed)
        
        if isAlive == false {
            moveForward = SKAction.moveTo(y: self.frame.minY + (floorHeight - playerY), duration: ballSpeed + 3.0)
        }
        
        let destroy = SKAction.removeFromParent()
        ball?.run(SKAction.sequence([moveForward, destroy]))
        
        self.addChild(ball!)
    }
    func ballSpawnTimer() {
        let ballTimer = SKAction.wait(forDuration: ballTimerSpawn)
        let spawn = SKAction.run {
            self.spawnBall()
        }
        let sequence = SKAction.sequence([ballTimer, spawn ])
        self.run(SKAction.repeatForever(sequence))
    }
    func spawnFloor() {
        
        floor = SKSpriteNode(color: floorColor, size: CGSize(width: self.frame.width, height: floorMax))
        // floor = SKSpriteNode(color: floorColor, size: CGSize(width: self.frame.width), height: floorMax))
        // floor?.position = CGPoint(x: self.frame.midX, y: self.frame.minY - floorMax/floorAdjust)
        
        floor?.position = CGPoint(x: self.frame.midX, y: self.frame.minY - floorMax/floorAdjust)
        self.addChild(floor!)
    }
    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
        if(score == 11) {
            scoreLabel?.fontColor = UIColor.green
        } else if(score == 26){
            scoreLabel?.fontColor = UIColor.red
        }
    }
    
    func   spawnStatusLabel() {
        statusLabel = SKLabelNode(fontNamed: "Rockwell")
        statusLabel?.fontSize = 100
        statusLabel?.fontColor = labelTextColor
        statusLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 350)
        statusLabel?.text = "START"
        self.addChild(statusLabel!)
    }
    func   spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Rockwell")
        scoreLabel?.fontSize = 60
        scoreLabel?.fontColor = labelTextColor
        scoreLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 210)
        scoreLabel?.text = "Score: 0"
        self.addChild(scoreLabel!)
    }
    
    
    func hideStatusLabel(){
        
        let wait = SKAction.wait(forDuration: 3.0)
        let hideIt = SKAction.run {
            self.statusLabel?.alpha = 0.0
            //self.btnPausePlay.isHidden = false
        }
        let sequence = SKAction.sequence([wait,hideIt])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    func waitThenMoveToTitleScene(){
        self.btnPausePlay.removeFromSuperview()
        
        let wait = SKAction.wait(forDuration: 1.5)
        
        let tranisition = SKAction.run {
            self.statusLabel?.alpha = 0.0
            self.resetVariableOnStart()
            
            self.view?.presentScene(TitleScene(), transition:
            SKTransition.crossFade(withDuration: 1.5))
        }
        let sequence = SKAction.sequence([wait, tranisition])
        self.run(SKAction.repeat(sequence, count: 1))
        
    }
    func addToScore(){
        let timeInterval = SKAction.wait(forDuration: 1.0)
        let addAndUpdateScore = SKAction.run{
            if self.isAlive == true {
                self.score = self.score + 1
                self.updateScore()
                // raise the floor/player every second too.
                self.floorHeight += 10.0
                self.floor?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + self.floorHeight - self.floorMax/self.floorAdjust)
                
            }
        }
        let sequence = SKAction.sequence([timeInterval, addAndUpdateScore])
        self.run(SKAction.repeatForever(sequence))
    }
    func leftRightX() -> Int {
        var leftRightRange = Int(arc4random_uniform(UInt32(self.frame.maxX*2)))
        if leftRightRange < Int(self.frame.maxX){
            leftRightRange = leftRightRange * -1}
        else {
            leftRightRange = leftRightRange - Int(self.frame.maxX)
        }
        return leftRightRange
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
            if isAlive == true {
                player?.position.x = (touchLocation?.x)!
                 playerX = (player?.position.x)!
            }
            if isAlive == false {
                player?.position.x = -1000
            }
        }
      
    }
    func spawnSmoke(playerTemp: SKSpriteNode) {
        let explosion = newSmokeParticle()!
        
        explosion.position = CGPoint(x: playerTemp.position.x, y:
        playerTemp.position.y)
        explosion.zPosition = 1
        explosion.targetNode = self
        
        self.addChild(explosion)
        let explosionTimerRemove = SKAction.wait(forDuration: 2.0)
        
        let removeExplosion = SKAction.run {
            explosion.removeFromParent()
        }
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
        
    }

    func newSmokeParticle() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "SmokeParticle.sks")
    }
    
    func spawnPausePlayButton() {
        let btnSize : CGFloat = 100
        
        btnPausePlay = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize))
        btnPausePlay.backgroundColor = UIColor.clear
        btnPausePlay.center = CGPoint(x: 75, y:sizeOfView.height - 75)
        let btnImage = UIImage(named: "pauseplay")
        btnPausePlay.setImage(btnImage, for: UIControl.State.normal)
        
        btnPausePlay.addTarget(self, action: (#selector(GameScene.pausePlayTheGame)),
                               for: UIControl.Event.touchUpInside)
        self.view?.addSubview(btnPausePlay)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // Mark: Private functions
    private func saveScores() {
        
        scores[0].score = highScore
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(scores, toFile: SavedGame.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("High Score succesfully saved." , log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save high score", log: OSLog.default, type: .error)
        }
    }
}
