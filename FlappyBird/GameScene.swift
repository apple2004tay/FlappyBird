//
//  GameScene.swift
//  FlappyBird
//
//  Created by User on 2020/11/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{

    var background = SKSpriteNode(imageNamed: "background")
    var floor1 = SKSpriteNode(imageNamed: "floor")
    var floor2 = SKSpriteNode(imageNamed: "floor")
    
    var birdAtlas = SKTextureAtlas(named: "player.atlas")
    var birdSprites = [SKTexture]()
    var bird = SKSpriteNode()
    
    var topPipe1 = SKSpriteNode(imageNamed: "topPipe")
    var topPipe2 = SKSpriteNode(imageNamed: "topPipe")
    var bottomPipe1 = SKSpriteNode(imageNamed: "bottomPipe")
    var bottomPipe2 = SKSpriteNode(imageNamed: "bottomPipe")
    
    let topPipeY = CGFloat(700)
    let bottomPipeY = CGFloat(150)
    let pipeStartX = CGFloat(600)
    let pipeEndX = CGFloat(-50)
    var pipeHeight = CGFloat(200)
    let pipeSpacing = CGFloat(350)
    let pipeScale = CGFloat(1.5)
    let pipeRandomRangeFrom = CGFloat(-50)
    let pipeRandomRangeMax = CGFloat(130)
    
    let pipeMoveYRange = CGFloat(80)
    var pipeMoveYDistance = CGFloat(1)
    var pipeCurrentMoveYRange = CGFloat(0)
    
    var bottomPipe1Passed = false
    var bottomPipe2Passed = false
    
    let birdCategory : UInt32 = 0x1 << 0
    let pipeCategory : UInt32 = 0x1 << 1
    
    var start = false
    var birdIsActive = false
    
    var moveSpeed = CGFloat(6);
    
    var gameover = false
    var score = 0
    let scoreLabel = UILabel()
    
    override func didMove(to view: SKView)
    {
        setBackground()
        setPipe()
        setFloor()
        setBird()
        createFloorPhysics()
        createPipePhysics()
        createScore()
    }
    
    func setBackground()
    {
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.init(x: 0, y: 0)
        addChild(background)
    }
    
    func setPipe()
    {
        bottomPipe1.position = CGPoint.init(x: pipeStartX, y: bottomPipeY);
        bottomPipe1.size.height = bottomPipe1.size.height / pipeScale
        bottomPipe1.size.width = bottomPipe1.size.width / pipeScale
         
        bottomPipe2.position = CGPoint.init(x: pipeStartX + pipeSpacing, y: bottomPipeY);
        bottomPipe2.size.height = bottomPipe2.size.height / pipeScale
        bottomPipe2.size.width = bottomPipe2.size.width / pipeScale
         
        topPipe1.position = CGPoint.init(x: pipeStartX, y: topPipeY);
        topPipe1.size.height = topPipe1.size.height / pipeScale
        topPipe1.size.width = topPipe1.size.width / pipeScale
         
        topPipe2.position = CGPoint.init(x: pipeStartX + pipeSpacing, y: topPipeY);
        topPipe2.size.height = topPipe2.size.height / pipeScale
        topPipe2.size.width = topPipe2.size.width / pipeScale
        
        addChild(self.bottomPipe1)
        addChild(self.bottomPipe2)
        addChild(self.topPipe1)
        addChild(self.topPipe2)
    }
    
    func setFloor()
    {
        floor1.anchorPoint = CGPoint.zero
        floor1.position = CGPoint.init(x: 0, y: 0)
        floor2.anchorPoint = CGPoint.zero
        floor2.position = CGPoint.init(x: floor1.size.width - 1, y: 0)
        addChild(floor1)
        addChild(floor2)
    }
    
    func setBird()
    {
        
        birdSprites.append(birdAtlas.textureNamed("player1"))
        birdSprites.append(birdAtlas.textureNamed("player2"))
        birdSprites.append(birdAtlas.textureNamed("player3"))
        birdSprites.append(birdAtlas.textureNamed("player4"))
        
        bird = SKSpriteNode(texture: birdSprites[0])
        bird.position = CGPoint(x: frame.midX / 2, y: frame.midY)
        bird.size.width = bird.size.width / 7
        bird.size.height = bird.size.height / 7
        
        let animationBird = SKAction.animate(with: birdSprites, timePerFrame: 0.1)
        let repeatAction = SKAction.repeatForever(animationBird)
        bird.run(repeatAction)
        addChild(bird)
    }
    
    func createFloorPhysics()
    {
        self.physicsBody = SKPhysicsBody.init(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
         
        floor1.physicsBody = SKPhysicsBody.init(edgeLoopFrom: floor1.frame)
         
        floor2.physicsBody = SKPhysicsBody.init(edgeLoopFrom: floor1.frame)
    }
    
    func createPipePhysics()
    {
        bottomPipe1.physicsBody?.categoryBitMask = pipeCategory
        bottomPipe1.physicsBody?.contactTestBitMask = birdCategory
         
        bottomPipe2.physicsBody?.categoryBitMask = pipeCategory
        bottomPipe2.physicsBody?.contactTestBitMask = birdCategory
         
        topPipe1.physicsBody?.categoryBitMask = pipeCategory
        topPipe1.physicsBody?.contactTestBitMask = birdCategory
         
        topPipe2.physicsBody?.categoryBitMask = pipeCategory
        topPipe2.physicsBody?.contactTestBitMask = birdCategory
        
        bottomPipe1.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "bottomPipe"), size: self.bottomPipe1.size)
         
        bottomPipe2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "bottomPipe"), size: self.bottomPipe2.size)
         
        topPipe1.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "topPipe"), size: self.topPipe1.size)
         
        topPipe2.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "topPipe"), size: self.topPipe2.size)
        
        bottomPipe1.physicsBody?.isDynamic = false
        bottomPipe2.physicsBody?.isDynamic = false
        topPipe1.physicsBody?.isDynamic = false
        topPipe2.physicsBody?.isDynamic = false
    }
    
    func createBirdPhysics()
    {
        bird.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(bird.size.height / 3))
         
        bird.physicsBody?.linearDamping = 1.1
        bird.physicsBody?.restitution = 0
         
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.contactTestBitMask = pipeCategory
        bird.physicsBody?.restitution = 0.5
        
        birdIsActive = true
    }
    
    func createScore()
    {
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 40)
        scoreLabel.frame = CGRect(x: (self.view?.center.x ?? 100) - 50, y: 20, width: 100, height: 100)
        scoreLabel.textAlignment = .center
        scoreLabel.text = "0"
        self.view?.addSubview(scoreLabel)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        updateFloorPos()
        
        if (start)
        {
            updatePipe()
            checkPassPipe()
        }
    }
    
    func updateFloorPos()
    {
        floor1.position = CGPoint.init(x: floor1.position.x - moveSpeed, y: floor1.position.y);
        floor2.position = CGPoint.init(x: floor2.position.x - moveSpeed, y: floor2.position.y);
         
        if (floor1.position.x < -floor1.size.width)
        {
            floor1.position = CGPoint.init(x: floor2.position.x + floor2.size.width, y: floor1.position.y);
        }
         
        if (floor2.position.x < -floor2.size.width)
        {
            floor2.position = CGPoint.init(x: floor1.position.x + floor1.size.width, y: floor2.position.y);
        }
    }
    
    func updatePipe()
    {
        if (score > 10)
        {
            bottomPipe1.position = CGPoint.init(x: bottomPipe1.position.x - moveSpeed , y: bottomPipe1.position.y + (pipeMoveYDistance * -1));
            bottomPipe2.position = CGPoint.init(x: bottomPipe2.position.x - moveSpeed, y: bottomPipe2.position.y + pipeMoveYDistance);
            topPipe1.position = CGPoint.init(x: topPipe1.position.x - moveSpeed, y: topPipe1.position.y + (pipeMoveYDistance * -1));
            topPipe2.position = CGPoint.init(x: topPipe2.position.x - moveSpeed, y: topPipe2.position.y + pipeMoveYDistance);
            
            pipeCurrentMoveYRange += abs(pipeMoveYDistance)
            
            if (pipeCurrentMoveYRange >= pipeMoveYRange)
            {
                pipeCurrentMoveYRange = 0
                pipeMoveYDistance *= -1
            }
        }
        else
        {
            bottomPipe1.position = CGPoint.init(x: bottomPipe1.position.x - moveSpeed , y: bottomPipe1.position.y);
            bottomPipe2.position = CGPoint.init(x: bottomPipe2.position.x - moveSpeed, y: bottomPipe2.position.y);
            topPipe1.position = CGPoint.init(x: topPipe1.position.x - moveSpeed, y: topPipe1.position.y);
            topPipe2.position = CGPoint.init(x: topPipe2.position.x - moveSpeed, y: topPipe2.position.y);
        }
         
        if (bottomPipe1.position.x < pipeEndX)
        {
            pipeHeight = randomBetweenNumbers(from: pipeRandomRangeFrom, to: pipeRandomRangeMax)
            bottomPipe1.position = CGPoint.init(x: pipeStartX, y: bottomPipeY + pipeHeight);
            topPipe1.position = CGPoint.init(x: pipeStartX, y: topPipeY + pipeHeight);
            bottomPipe1Passed = false
        }
         
        if (bottomPipe2.position.x < pipeEndX)
        {
            pipeHeight = randomBetweenNumbers(from: pipeRandomRangeFrom, to: pipeRandomRangeMax)
            bottomPipe2.position = CGPoint.init(x: pipeStartX, y: bottomPipeY + pipeHeight);
            topPipe2.position = CGPoint.init(x: pipeStartX, y: topPipeY + pipeHeight);
            bottomPipe2Passed = false
        }
    }
    
    func randomBetweenNumbers(from : CGFloat, to : CGFloat) -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(from - to) + min(from, to)
    }
    
    func checkPassPipe()
    {
        if (!gameover)
        {
            if (!bottomPipe1Passed && bottomPipe1.position.x < bird.position.x)
            {
                bottomPipe1Passed = true
                addScore()
            }
            
            if (!bottomPipe2Passed && bottomPipe2.position.x < bird.position.x)
            {
                bottomPipe2Passed = true
                addScore()
            }
        }
    }
    
    func addScore()
    {
        score += 1
        scoreLabel.text = "\(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        start = true
        
        if (!gameover)
        {
            if (birdIsActive)
            {
                self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 75))
            }
            else
            {
                createBirdPhysics()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if (birdIsActive)
        {
            gameover = true
            birdIsActive = false
            bird.removeAllActions()
            bird.physicsBody?.angularVelocity = -moveSpeed * 1.5
            moveSpeed = CGFloat(0)
            
            createResetButton()
        }
    }
    
    func createResetButton()
    {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Reset", for: .normal)
        button.layer.cornerRadius = 5
        button.frame = CGRect(x: (self.view?.center.x ?? 100) - 50, y: 100, width: 100, height: 50)
        button.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        self.view?.addSubview(button)
    }
    
    @objc func resetGame()
    {
        if let scene = SKScene(fileNamed: "GameScene")
        {
            scene.scaleMode = .aspectFill
            self.view?.subviews.forEach({$0.removeFromSuperview()})
            self.view?.presentScene(scene)
        }
    }
}
