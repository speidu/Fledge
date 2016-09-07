//
//  GameScene.swift
//
//
//  Created by Teemu on 13.2.2016.
//  Copyright (c) 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func didMoveToView(view: SKView) {
        stuffInTheScene = false
        isAlive = true
        platformLocation = 2 // Force variable gap as first obstacle
        
        // Background color
        backgroundColor = skyColor
        
        // Physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -1.5)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.speed = 1
        
        // Swipe up and down gesture recognizers
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view!.addGestureRecognizer(swipeDown)
        
        // BottomPlatform properties
        bottomPlatform.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, BottomPlatformTexture.size().height))
        bottomPlatform.physicsBody?.dynamic = false
        bottomPlatform.physicsBody?.categoryBitMask = platformCategory
        bottomPlatform.physicsBody?.collisionBitMask = playerCategory
        bottomPlatform.physicsBody?.contactTestBitMask = playerCategory
        bottomPlatform.physicsBody?.restitution = 0.0
        bottomPlatform.physicsBody?.affectedByGravity = false
        
        // TopPlatform properties
        topPlatform.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, TopPlatformTexture.size().height))
        topPlatform.physicsBody?.dynamic = false
        topPlatform.physicsBody?.categoryBitMask = platformCategory
        topPlatform.physicsBody?.collisionBitMask = playerCategory
        topPlatform.physicsBody?.contactTestBitMask = playerCategory
        topPlatform.physicsBody?.restitution = 0.0
        topPlatform.physicsBody?.affectedByGravity = false
        
        // Call an instance of Player and setup Player properties
        player = Player(size: CGSizeMake(PlayerTexture1.size().width, PlayerTexture1.size().height))
        player.position = CGPointMake(self.frame.size.width / 2.8, self.frame.size.height * 0.5 - 50)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.0
        player.name = "playerNode"
        
        // Moving & platforms node
        addChild(moving)
        
        // Call an instance of Top, Bottomplatform, Bottomground, Mountains and Background classes
        let screenHeight = self.screenSize.height
        
        switch screenHeight { // For moving top sprites
            case 569...667: // Setup moving top background sprites for iphone 6 size
                movingTopBackground = Background(size: CGSizeMake(backgroundTextureIphone6.size().width, backgroundTextureIphone6.size().height))
                movingTopMountains = Mountains(size: CGSizeMake(topMountainsTextureIphone6.size().width, topMountainsTextureIphone6.size().height))
                movingTopMountainsBackground = MountainsBackground(size: CGSizeMake(topMountainsBackgroundTextureIphone6.size().width, topMountainsBackgroundTextureIphone6.size().height))
            default:
                // Otherwise use defaults
                movingTopBackground = Background(size: CGSizeMake(backgroundTexture.size().width, backgroundTexture.size().height))
                movingTopMountains = Mountains(size: CGSizeMake(topMountainsTexture.size().width, topMountainsTexture.size().height))
                movingTopMountainsBackground = MountainsBackground(size: CGSizeMake(topMountainsBackgroundTexture.size().width, topMountainsBackgroundTexture.size().height))
        }
        
        movingBottomPlatform = BottomPlatform(size: CGSizeMake(BottomPlatformTexture.size().width, BottomPlatformTexture.size().height))
        movingTopPlatform = TopPlatform(size: CGSizeMake(TopPlatformTexture.size().width, TopPlatformTexture.size().height))

        if screenHeight > 480 { // No bottom ground texture for iphone 4 - doesnt fit in screen
            movingBottomGround = Bottomground(size: CGSizeMake(bottomGroundTexture.size().width, bottomGroundTexture.size().height))
            moving.addChild(movingBottomGround)
        }
        
        moving.addChild(movingBottomPlatform)
        moving.addChild(movingTopPlatform)
        moving.addChild(movingTopMountains)
        moving.addChild(movingTopMountainsBackground)
        moving.addChild(movingTopBackground)
        
        // Background sprite (tunnel)
        let tunnel = SKSpriteNode(texture: tunnelTexture)
        tunnel.zPosition = 1
        tunnel.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // highscore & Scorelabel setup
        highscore = userSettingsDefaults.integerForKey("Highscore")
        
        score = 0
        scoreLabel.fontName = "Avenir Next"
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 45
        scoreLabel.zPosition = 4
        
        // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
        switch screenHeight {
        case 0...480:
            // Iphone 4
            topPlatform.position = CGPointMake(self.frame.width / 2, 358)
            bottomPlatform.position = CGPointMake(self.frame.width / 2, movingBottomPlatform.size.height / 2)
            scoreLabel.position = CGPointMake(30, 310)
            scoreLabel.fontSize = 35 // Smaller font for iphone 4
            tunnel.position = CGPointMake(self.frame.size.width / 2, movingBottomPlatform.size.height)
        case 481...568:
            // Iphone 5
            topPlatform.position = CGPointMake(self.frame.width / 2, 438)
            bottomPlatform.position = CGPointMake(self.frame.width / 2, 80)
            scoreLabel.position = CGPointMake(self.frame.size.width / 2, 20)
            tunnel.position = CGPointMake(self.frame.size.width / 2, 80)
        case 569...667:
            // Iphone 6
            topPlatform.position = CGPointMake(self.frame.width / 2, 468)
            bottomPlatform.position = CGPointMake(self.frame.width / 2, 110)
            scoreLabel.position = CGPointMake(self.frame.size.width / 2, 55)
            tunnel.position = CGPointMake(self.frame.size.width / 2, 110)
        default:
            // Iphone 6 plus
            topPlatform.position = CGPointMake(self.frame.width / 2, 508)
            bottomPlatform.position = CGPointMake(self.frame.width / 2, 150)
            scoreLabel.position = CGPointMake(self.frame.size.width / 2, 75)
            tunnel.position = CGPointMake(self.frame.size.width / 2, 150)
        }
        
        moving.addChild(bottomPlatform) //Device height checked, add everything to scene
        moving.addChild(topPlatform)
        moving.addChild(coins)
        moving.addChild(tunnel)
        moving.addChild(scoreLabel)
        moving.addChild(player)
        moving.speed = 1
        
        if stuffInTheScene == false { // Add things to scene and start the game
            addToScene()
            startSpawningPlatforms()
            beginPlayingBackgroundMusic()
            stuffInTheScene = true
        }
    }
    
    // Setup sound effects
    func beginPlayingBackgroundMusic() {
        // Checking whether audio is muted or not
        muted = userSettingsDefaults.boolForKey("Muted")
        
        if backgroundMusic != nil {
            let audioURL = NSURL.fileURLWithPath(backgroundMusic!)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: audioURL)
                backgroundMusicPlayer.numberOfLoops = -1
                backgroundMusicPlayer.prepareToPlay()
            } catch {
                // combine catch
                print("Can't find audio file")
            }
        }
        
        if hitSound != nil {
            let audioURL = NSURL.fileURLWithPath(hitSound!)
            do {
                hitSoundPlayer = try AVAudioPlayer(contentsOfURL: audioURL)
                hitSoundPlayer.prepareToPlay()
            } catch {
                // combine catch
                print("Can't find audio file")
            }
        }
        
        if (muted == false) {
            backgroundMusicPlayer.play()
        }
    }
    
    // Call splawnPlatforms function nth second
    func startSpawningPlatforms() {
        // platformSpawnTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(GameScene.spawnPlatforms), userInfo: nil, repeats: true)
        let actionwait = SKAction.waitForDuration(1.55)
        let actionrun = SKAction.runBlock({
            self.spawnPlatforms()
        })
        
     /*   let coinWait = SKAction.waitForDuration(0.2) // 5.425
        let coinRun = SKAction.runBlock({
            self.spawnCoins()
        }) */
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([actionwait,actionrun])), withKey: "platformSpawn")
      //  self.runAction(SKAction.repeatActionForever(SKAction.sequence([coinWait,coinRun])), withKey: "coinSpawn")
        
    }
    
    //Determine platform spawn location
    func DeterminePlatformLocation(previousPlatformLocation: Int) -> Int {
        //Check previous platform location
        while spawnLocation == previousPlatformLocation { // Force different spawn every time
            spawnLocation = Int(arc4random_uniform(3))
        }
        if previousPlatformLocation != 1 { // Every second spawn should be 2 platforms with variable gap
            spawnLocation = 1
        }
        return spawnLocation
    }
    
    func spawnPlatforms() { // Platform spawn logic
        
        platformSpawned = true
        
        //Platform texture setup
        let platform = SKSpriteNode(texture: platformSmall1)
        let platform2 = SKSpriteNode(texture: platformSmall1)
        let scoreNode = SKSpriteNode()
        
        // Access the current screen width
        let screenWidth = screenSize.height
        
        let newLocation = DeterminePlatformLocation(platformLocation)
        platformLocation = newLocation
        
        if newLocation == 1 || newLocation == 2 { // If more than 1 platform, setup platform2 properties
            platform2.zPosition = 2
            platform2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(platform.size.width, platform.size.height))
            platform2.physicsBody?.dynamic = false
            platform2.physicsBody?.categoryBitMask = platformCategory
            platform2.physicsBody?.collisionBitMask = playerCategory
            platform2.physicsBody?.contactTestBitMask = playerCategory
            platform2.physicsBody?.allowsRotation = false
            platform2.physicsBody?.restitution = 0.0
            platform2.physicsBody?.affectedByGravity = false
            platform2.name = "platform2Node"
        }
        
        let randomAddedHeight =  CGFloat(arc4random_uniform(25))
        let baseAddedHeightSingleSpawn : CGFloat = 100 + randomAddedHeight
        let randomAddedHeightDualSpawnPlatforms = CGFloat(arc4random_uniform(65))
        let coinFlip = arc4random_uniform(2) // For double spawns - gap up or down
        let frameWidth = self.frame.size.width
        
        switch newLocation { //Check newlocation and setup platform locations
            
        case 0: // Setup single platform spawn location
            
            let platformUpOrDown = Int(arc4random_uniform(2))
            
            if platformUpOrDown == 0 { // single bottom spawn
                
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    platform.position = CGPointMake(frameWidth + platform.size.width, -23 + baseAddedHeightSingleSpawn)
                case 481...568:
                    // Iphone 5
                    platform.position = CGPointMake(frameWidth + platform.size.width, 57 + baseAddedHeightSingleSpawn)
                case 569...667:
                    // Iphone 6
                    platform.position = CGPointMake(frameWidth + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                default:
                    // Iphone 6 plus
                    platform.position = CGPointMake(frameWidth + platform.size.width, 128 + baseAddedHeightSingleSpawn)
                }
            } else if platformUpOrDown == 1 { // Single top spawn
                
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    platform.position = CGPointMake(frameWidth + platform.size.width, 390 - baseAddedHeightSingleSpawn)
                case 481...568:
                    // Iphone 5
                    platform.position = CGPointMake(frameWidth + platform.size.width, 461 - baseAddedHeightSingleSpawn)
                case 569...667:
                    // Iphone 6
                    platform.position = CGPointMake(frameWidth + platform.size.width, 491 - baseAddedHeightSingleSpawn)
                default:
                    // Iphone 6 plus
                    platform.position = CGPointMake(frameWidth + platform.size.width, 530 - baseAddedHeightSingleSpawn)
                }
            }
        case 1: // Setup Double platform spawn (Up and down)
            switch screenWidth {
            case 0...480: // Iphone 4
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, -23 + randomAddedHeightDualSpawnPlatforms + 15)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 390 + randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width, -23 - randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 390 - randomAddedHeightDualSpawnPlatforms - 15) // 475 Bottom of topplatform 94 difference
                }
                moving.addChild(platform2)
            case 481...568: // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 57 + randomAddedHeightDualSpawnPlatforms + 15) // -37 top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 461 + randomAddedHeightDualSpawnPlatforms) // 555 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 57 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPointMake(frameWidth + platform.size.width, 461 - randomAddedHeightDualSpawnPlatforms - 15)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 87 + randomAddedHeightDualSpawnPlatforms + 15) // -7 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 491 + randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 87 - randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 491 - randomAddedHeightDualSpawnPlatforms - 15) // 585 Bottom of topplatform
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 128 + randomAddedHeightDualSpawnPlatforms + 15) // 34 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 530 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 128 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 530 - randomAddedHeightDualSpawnPlatforms - 15) // 624 bottom of topplatform
                }
                moving.addChild(platform2)
            }
            
        case 2: // Two platforms spawn a little apart from eachother
            switch screenWidth {
            case 0...480: // Iphone 4
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 33 + randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width + 85, 340 + randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width + 85, 33 - randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 340 - randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                }
                moving.addChild(platform2)
            case 481...568: // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down 57
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 107 + randomAddedHeightDualSpawnPlatforms) // -37 top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width + 85, 411 + randomAddedHeightDualSpawnPlatforms) // 555 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width + 85, 107 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPointMake(frameWidth + platform.size.width, 411 - randomAddedHeightDualSpawnPlatforms)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 137 + randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width + 85, 441 + randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width + 85, 137 - randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 441 - randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(frameWidth + platform.size.width, 178 + randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width + 85, 480 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(frameWidth + platform.size.width + 85, 178 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPointMake(frameWidth + platform.size.width, 480 - randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                }
                moving.addChild(platform2)
            }
            
        case 3: // Spawn a single platform that moves up/down
            switch screenWidth {
            case 0...480: // Iphone 4
                platform.position = CGPointMake(frameWidth + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            case 481...568: // Iphone 5
                platform.position = CGPointMake(frameWidth + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                platform.position = CGPointMake(frameWidth + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            default: // Iphone 6 plus
                platform.position = CGPointMake(frameWidth + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            }
        default:
            break
        }
        
        // Setup platform and add to scene
        platform.zPosition = 2
        platform.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(platform.size.width, platform.size.height))
        platform.physicsBody?.dynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.collisionBitMask = playerCategory
        platform.physicsBody?.contactTestBitMask = playerCategory
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.restitution = 0.0
        platform.physicsBody?.affectedByGravity = false
        platform.name = "platformNode"
        moving.addChild(platform)
        
        // Setup scoreNode for scorekeeping
        scoreNode.position = CGPointMake(self.frame.size.width + (platform.size.width * 6), CGRectGetMidY(self.frame))
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, self.frame.height))
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = playerCategory
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.zPosition = 1
        scoreNode.name = "scoreNode"
        moving.addChild(scoreNode)
        
        // Platform moving time
        let moveDuration = NSTimeInterval(frameWidth * 0.0070)
        
        // Move platform, platform2, scoreNode and remove from scene
        let movePlatform = SKAction.moveByX(-frameWidth - platformSmall1.size().width * 2 - 85, y: 0, duration: moveDuration )
        let removePlatform = SKAction.removeFromParent()
        let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
        
        platform.runAction(movePlatformAndRemove, completion: setSpawnedToFalse)
        if newLocation == 1 || newLocation == 2 { // Only apply action to platform2 if being used
            platform2.runAction(movePlatformAndRemove)
        }
        scoreNode.runAction(movePlatformAndRemove)
    }
    
    func setSpawnedToFalse() {
        platformSpawned = false
    }
    
  /*  func spawnCoins() {
        
        if (platformSpawned == false && coinSpawned == false) {
            
            // Setting up coins
            coin = SKSpriteNode(texture: coinTexture)
            coin.texture = SKTexture(imageNamed: "Coin")
            coin.zPosition = 2
            coin.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(coin.size.width, coin.size.height))
            coin.physicsBody?.dynamic = false
            coin.physicsBody?.categoryBitMask = coinCategory
            coin.physicsBody?.collisionBitMask = playerCategory
            coin.physicsBody?.contactTestBitMask = playerCategory
            coin.physicsBody?.allowsRotation = false
            coin.physicsBody?.restitution = 0.0
            coin.physicsBody?.affectedByGravity = false
            coin.name = "coinNode"
            
            let screenWidth = self.screenSize.height
            let determineCoinSpawn = arc4random_uniform(6)
            let coinSpawnLocation = arc4random_uniform(4)
            let coinMovement = arc4random_uniform(2)
            
            switch determineCoinSpawn {
            case 0...1:
                break
            case 2...5:
                switch coinSpawnLocation {
                case 0:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.18)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.27)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.27)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.29)
                    }
                case 1:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.30)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.35)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.37)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.36)
                    }
                case 2:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.50)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.53)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.50)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.54)
                    }
                case 3:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.61)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.64)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.59)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPointMake(self.frame.size.width + coin.frame.width, self.frame.size.height * 0.61)
                    }
                default:
                    break
                }
                
            default:
                break
            }
            
            moving.addChild(coin)
            // delayCoinSpawn()
            // Platform moving time
            // let moveDuration = NSTimeInterval(self.frame.size.width * 0.0055) // default 0.0055
            let moveDuration = NSTimeInterval(self.frame.size.width * 0.0070)
            
            // Move platform, platform2, scoreNode and remove from scene
            let movePlatform = SKAction.moveByX(-self.frame.size.width - platformSmall1.size().width * 2 - 85, y: 0, duration: moveDuration )
            let removePlatform = SKAction.removeFromParent()
            let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
            let moveCoinUp = SKAction.moveByX(0, y: 350, duration: 5.0)
            let moveCoinDown = SKAction.moveByX(0, y: -350, duration: 5.0)
            switch coinMovement {
            case 0:
                break
            case 1:
                if (coinSpawnLocation == 0) {
                    coin.runAction(moveCoinUp)
                } else if (coinSpawnLocation == 1) {
                    coin.runAction(moveCoinUp)
                } else if (coinSpawnLocation == 3) {
                    coin.runAction(moveCoinDown)
                } else {
                    coin.runAction(moveCoinDown)
                }
            default:
                break
            }
            
            coin.runAction(movePlatformAndRemove)
            // coin.runAction(moveCoinUp, withKey: "CoinUp")
        }
 
    } */
    
    func didBeginContact(contact: SKPhysicsContact) {
        if isAlive { // Check if player is alive, otherwise do nothing
            if (contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory){
                score += 1 // Increment score && update scoreLabel text
                scoreLabel.text = "\(score)"
                
            } else if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == coinCategory || contact.bodyA.categoryBitMask == coinCategory && contact.bodyB.categoryBitMask == playerCategory) {
                score += 5 // Increments score by 5 and makes the coin disappear
             /*   moving.enumerateChildNodesWithName("coinNode") {
                    node, stop in
                    node.removeFromParent()
                }
                // Delays adding the coin back to the moving node, so the same coin you collected won't show up again
                addCoinToParent() */
                
                scoreLabel.text = "\(score)" // Update scoreLabels text
            } else if (contact.bodyA.categoryBitMask == platformCategory || contact.bodyB.categoryBitMask == platformCategory) {
                // Player has died, stop the game && stop spawning platforms
                self.removeActionForKey("platformSpawn")
           //     self.removeActionForKey("coinSpawn")
                isAlive = false
                moving.speed = 0
                moving.enumerateChildNodesWithName("platformNode") {
                    node, stop in
                    node.removeFromParent()
                }
                moving.enumerateChildNodesWithName("platform2Node") {
                    node, stop in
                    node.removeFromParent()
                }
                moving.enumerateChildNodesWithName("scoreNode") {
                    node, stop in
                    node.removeFromParent()
                }
             /*   moving.enumerateChildNodesWithName("coinNode") {
                    node, stop in
                     node.removeFromParent()
                } */
                /*let coinNode = moving.childNodeWithName("coinNode")
                coinNode?.removeFromParent() */
                scoreLabel.removeFromParent()
                
                if (backgroundMusicPlayer.playing) {
                    backgroundMusicPlayer.stop()
                }
                if (muted == false) {
                    hitSoundPlayer.play()
                }
                
                // Jump back a bit after colliding
                player.physicsBody?.applyImpulse(CGVectorMake(-15, 30))
                self.physicsWorld.gravity = CGVectorMake(0.0, -6.5)
                
                // If current score is higher than highscore stored in device memory then set highscore as current score
                if (score > highscore) {
                    highscore = score
                    userSettingsDefaults.setInteger(highscore, forKey: "Highscore")
                    newHighscore = true
                }
                
                if (newHighscore) { // Add gameover label + back to menu and restart button
                    gameOverLabel.text = "New highscore! \n \(score)"
                    gameOverLabel.font = UIFont(name: "Avenir Next", size: 34)
                } else {
                    gameOverLabel.text = "Score: \(score)"
                    gameOverLabel.font = UIFont(name: "Avenir Next", size: 40)
                }
                gameOverLabel.numberOfLines = 0
                gameOverLabel.layer.anchorPoint = CGPointMake(1.0, 1.0)
                gameOverLabel.textColor = UIColor.whiteColor()
                gameOverLabel.layer.zPosition = 2
                gameOverLabel.textAlignment = NSTextAlignment.Center
                
                // Create a play again button called restartGameButton
                restartGameButton = UIButton(type: UIButtonType.Custom)
                restartGameButton.setImage(restartGameButtonImage, forState: .Normal)
                restartGameButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
                restartGameButton.layer.zPosition = 2
                restartGameButton.addTarget(self, action: #selector(GameScene.restartGameButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                // Create a backToMainMenuButton to go back to menu
                backToMainMenuButton = UIButton(type: UIButtonType.Custom)
                backToMainMenuButton.setImage(restartGameButtonImage, forState: .Normal)
                backToMainMenuButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
                backToMainMenuButton.layer.zPosition = 2
                backToMainMenuButton.addTarget(self, action: #selector(GameScene.backToMainMenuButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                // muteButton Setup
                muteButton = UIButton(type: UIButtonType.Custom) as UIButton!
                if (muted == false) {
                    muteButton.setImage(unmutedImage, forState: .Normal)
                } else {
                    muteButton.setImage(mutedImage, forState: .Normal)
                }
                muteButton.layer.anchorPoint = CGPointMake(1.0, 1.0)
                muteButton.layer.zPosition = 5
                muteButton.addTarget(self, action: #selector(GameScene.muteAudio(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                // Access the current screen width
                let screenWidth = self.screenSize.height
                
                // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 125, 100, 250, 200)
                    backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    restartGameButton.frame = CGRectMake(restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.8, 80, 80)
                case 481...568:
                    // Iphone 5
                    gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 125, 140, 250, 200)
                    backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    restartGameButton.frame = CGRectMake(restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.8, 80, 80)
                case 569...667:
                    // Iphone 6
                    gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 125, 210, 250, 200)
                    backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    restartGameButton.frame = CGRectMake(restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.85, 80, 80)
                default:
                    // Iphone 6 plus
                    gameOverLabel.font = UIFont(name: "Avenir Next", size: 45)
                    gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 175, 210, 350, 200)
                    backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    restartGameButton.frame = CGRectMake(restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.85, 80, 80)
                }
                
                // Locations configured, add to view
                self.view!.addSubview(gameOverLabel)
                self.view!.addSubview(backToMainMenuButton)
                self.view!.addSubview(restartGameButton)
                self.view!.addSubview(muteButton)
                
                self.physicsWorld.gravity = CGVectorMake(0.0, -6.5)
                
                // Animate the buttons
                UIView.animateWithDuration(0.5, animations: {
                    restartGameButton.layer.position.x =  self.frame.size.width - self.frame.size.width * 0.3
                    backToMainMenuButton.layer.position.x = self.frame.size.width - self.frame.size.width * 0.7
                    muteButton.layer.position.x = self.frame.size.width - self.frame.size.width * 0.7
                })
            }
            
        }
    }
    
  /*  func addCoinToParent() {
    delay(1.0) {
        moving.addChild(coin)
    }
    } */
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if isAlive && stuffInTheScene { // Check if player is alive & game has started
            // Check swipe direction to change gravity direction (Up / Down)
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.Up: // Swipe up
                    self.physicsWorld.gravity = CGVectorMake(0.0, 6.5)
                case UISwipeGestureRecognizerDirection.Down: // Swipe down
                    self.physicsWorld.gravity = CGVectorMake(0.0, -6.5)
                default:
                    break
                }
            }
        }
    }
    
    func addToScene() {
        let screenHeight = self.screenSize.height
        if stuffInTheScene == false {
            movingBottomPlatform.begin()
            movingTopPlatform.begin()
            movingTopBackground.begin()
            movingTopMountains.begin()
            movingTopMountainsBackground.begin()
            player.startFlying()
            if screenHeight > 480 {
                movingBottomGround.begin() // for iPhone 4s - dont add movingBottomGround
            }
        }
    }
    
    func muteAudio(sender: UIButton!) {
        if (muted == false) {
            muted = true
            userSettingsDefaults.setBool(muted, forKey: "Muted")
            muteButton.setImage(mutedImage, forState: .Normal)
        } else {
            muted = false
            userSettingsDefaults.setBool(muted, forKey: "Muted")
            muteButton.setImage(unmutedImage, forState: .Normal)
        }
    }
    
    func restartGameButtonAction(sender: UIButton) {
        // Animate UIButton and UILabel
        UIView.animateWithDuration(0.5, animations: {
            restartGameButton.layer.position.x = self.frame.size.width + restartGameButton.frame.size.width
            backToMainMenuButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
            muteButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
        })
        
        // Call restart function after 0.5s delay
        delay(0.5) {
          /*  moving.removeAllChildren()
            moving.removeAllActions()
            moving.removeFromParent()
            self.removeAllChildren()
            self.removeAllActions() */
            self.restart("RestartGame")
        }
    }
    
    func backToMainMenuButtonAction(sender: UIButton) {
        // Animate UIButton and UILabel
        UIView.animateWithDuration(0.5, animations: {
            restartGameButton.layer.position.x = self.frame.size.width + restartGameButton.frame.size.width
            backToMainMenuButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
            muteButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
        })
        
        // Call restart function after 0.5s delay
        delay(0.5) {
            moving.removeAllChildren()
            moving.removeAllActions()
            moving.removeFromParent()
            self.removeAllChildren()
            self.removeAllActions()
            self.restart("BackToMenu")
        }
    }
    
    func restart(ButtonType: String) {
        // Restart the game
        // Remove labels and buttons
        restartGameButton.removeFromSuperview()
        gameOverLabel.removeFromSuperview()
        backToMainMenuButton.removeFromSuperview()
        muteButton.removeFromSuperview()
        
        
        // Setup transition to GameScene
        let skView = self.view! as SKView
        skView.ignoresSiblingOrder = true
        
        // Remove current scene before transitioning
        self.scene?.removeFromParent()
        
        // Transition effect
        let transition = SKTransition.fadeWithColor(backgroundColor, duration: 1.0)
        transition.pausesOutgoingScene = false
        
        // scene
        var scene: SKScene!
        if ButtonType == "RestartGame" {
            player.physicsBody?.dynamic = false
            score = 0
            self.physicsWorld.gravity = CGVectorMake(0.0, -1.5)
            player.position = CGPointMake(self.frame.size.width / 2.8, self.frame.size.height * 0.5 - 50)
            scoreLabel.text = "\(score)"
            moving.addChild(scoreLabel)
            isAlive = true
            moving.speed = 1
            player.physicsBody?.dynamic = true
            self.startSpawningPlatforms()
          /*  scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill */
        } else if ButtonType == "BackToMenu" {
            self.removeAllChildren()
            self.removeAllActions()
            self.removeFromParent()
            scene = MainMenuScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
            skView.presentScene(scene, transition: transition)

        }
        
        // Present new scene with transition effect
      //  skView.presentScene(scene, transition: transition)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func delay(delay: Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
}
