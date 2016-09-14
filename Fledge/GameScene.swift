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
    let screenSize: CGRect = UIScreen.main.bounds
    
    override func didMove(to view: SKView) {
        stuffInTheScene = false
        isAlive = true
        platformLocation = 2 // Force variable gap as first obstacle
        
        // Background color
        backgroundColor = skyColor
        
        // Physics
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.5)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.speed = 1
        
        // Swipe up and down gesture recognizers
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view!.addGestureRecognizer(swipeDown)
        
        // BottomPlatform properties
        bottomPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: BottomPlatformTexture.size().height))
        bottomPlatform.physicsBody?.isDynamic = false
        bottomPlatform.physicsBody?.categoryBitMask = platformCategory
        bottomPlatform.physicsBody?.collisionBitMask = playerCategory
        bottomPlatform.physicsBody?.contactTestBitMask = playerCategory
        bottomPlatform.physicsBody?.restitution = 0.0
        bottomPlatform.physicsBody?.affectedByGravity = false
        
        // TopPlatform properties
        topPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: TopPlatformTexture.size().height))
        topPlatform.physicsBody?.isDynamic = false
        topPlatform.physicsBody?.categoryBitMask = platformCategory
        topPlatform.physicsBody?.collisionBitMask = playerCategory
        topPlatform.physicsBody?.contactTestBitMask = playerCategory
        topPlatform.physicsBody?.restitution = 0.0
        topPlatform.physicsBody?.affectedByGravity = false
        
        // Call an instance of Player and setup Player properties
        player = Player(size: CGSize(width: PlayerTexture1.size().width, height: PlayerTexture1.size().height))
        player.position = CGPoint(x: self.frame.size.width / 2.8, y: self.frame.size.height * 0.5 - 50)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = true
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
                movingTopBackground = Background(size: CGSize(width: backgroundTextureIphone6.size().width, height: backgroundTextureIphone6.size().height))
                movingTopMountains = Mountains(size: CGSize(width: topMountainsTextureIphone6.size().width, height: topMountainsTextureIphone6.size().height))
                movingTopMountainsBackground = MountainsBackground(size: CGSize(width: topMountainsBackgroundTextureIphone6.size().width, height: topMountainsBackgroundTextureIphone6.size().height))
            default:
                // Otherwise use defaults
                movingTopBackground = Background(size: CGSize(width: backgroundTexture.size().width, height: backgroundTexture.size().height))
                movingTopMountains = Mountains(size: CGSize(width: topMountainsTexture.size().width, height: topMountainsTexture.size().height))
                movingTopMountainsBackground = MountainsBackground(size: CGSize(width: topMountainsBackgroundTexture.size().width, height: topMountainsBackgroundTexture.size().height))
        }
        
        movingBottomPlatform = BottomPlatform(size: CGSize(width: BottomPlatformTexture.size().width, height: BottomPlatformTexture.size().height))
        movingTopPlatform = TopPlatform(size: CGSize(width: TopPlatformTexture.size().width, height: TopPlatformTexture.size().height))

        if screenHeight > 480 { // No bottom ground texture for iphone 4 - doesnt fit in screen
            movingBottomGround = Bottomground(size: CGSize(width: bottomGroundTexture.size().width, height: bottomGroundTexture.size().height))
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
        highscore = userSettingsDefaults.integer(forKey: "Highscore")
        
        score = 0
        scoreLabel.fontName = "Avenir Next"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 45
        scoreLabel.zPosition = 4
        
        // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
        switch screenHeight {
        case 0...480:
            // Iphone 4
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 358)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: movingBottomPlatform.size.height / 2)
            scoreLabel.position = CGPoint(x: 30, y: 310)
            scoreLabel.fontSize = 35 // Smaller font for iphone 4
            tunnel.position = CGPoint(x: self.frame.size.width / 2, y: movingBottomPlatform.size.height)
        case 481...568:
            // Iphone 5
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 438)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: 80)
            scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: 20)
            tunnel.position = CGPoint(x: self.frame.size.width / 2, y: 80)
        case 569...667:
            // Iphone 6
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 468)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: 110)
            scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: 55)
            tunnel.position = CGPoint(x: self.frame.size.width / 2, y: 110)
        default:
            // Iphone 6 plus
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 508)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: 150)
            scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: 75)
            tunnel.position = CGPoint(x: self.frame.size.width / 2, y: 150)
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
        muted = userSettingsDefaults.bool(forKey: "Muted")
        
        if backgroundMusic != nil {
            let audioURL = URL(fileURLWithPath: backgroundMusic!)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: audioURL)
                backgroundMusicPlayer.numberOfLoops = -1
                backgroundMusicPlayer.prepareToPlay()
            } catch {
                // combine catch
                print("Can't find audio file")
            }
        }
        
        if hitSound != nil {
            let audioURL = URL(fileURLWithPath: hitSound!)
            do {
                hitSoundPlayer = try AVAudioPlayer(contentsOf: audioURL)
                hitSoundPlayer.prepareToPlay()
            } catch {
                // combine catch
                print("Can't find audio file")
            }
        }
        
        if coinSound != nil {
            let audioURL = URL(fileURLWithPath: coinSound!)
            do {
                coinSoundPlayer = try AVAudioPlayer(contentsOf: audioURL)
                coinSoundPlayer.prepareToPlay()
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
        let actionwait = SKAction.wait(forDuration: 1.55)
        let actionrun = SKAction.run({
            self.spawnPlatforms()
        })
        
        let coinWait = SKAction.wait(forDuration: 5.425) // 5.425 0.2
        let coinRun = SKAction.run({
            self.spawnCoins()
        })
        
        self.run(SKAction.repeatForever(SKAction.sequence([actionwait,actionrun])), withKey: "platformSpawn")
        self.run(SKAction.repeatForever(SKAction.sequence([coinWait,coinRun])), withKey: "coinSpawn")
        
    }
    
    //Determine platform spawn location
    func DeterminePlatformLocation(_ previousPlatformLocation: Int) -> Int {
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
            platform2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
            platform2.physicsBody?.isDynamic = false
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
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: -23 + baseAddedHeightSingleSpawn)
                case 481...568:
                    // Iphone 5
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 57 + baseAddedHeightSingleSpawn)
                case 569...667:
                    // Iphone 6
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + baseAddedHeightSingleSpawn)
                default:
                    // Iphone 6 plus
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 128 + baseAddedHeightSingleSpawn)
                }
            } else if platformUpOrDown == 1 { // Single top spawn
                
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 390 - baseAddedHeightSingleSpawn)
                case 481...568:
                    // Iphone 5
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 461 - baseAddedHeightSingleSpawn)
                case 569...667:
                    // Iphone 6
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 491 - baseAddedHeightSingleSpawn)
                default:
                    // Iphone 6 plus
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 530 - baseAddedHeightSingleSpawn)
                }
            }
        case 1: // Setup Double platform spawn (Up and down)
            switch screenWidth {
            case 0...480: // Iphone 4
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: -23 + randomAddedHeightDualSpawnPlatforms + 15)  //-15  -108 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 390 + randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: -23 - randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 390 - randomAddedHeightDualSpawnPlatforms - 15) // 475 Bottom of topplatform 94 difference
                }
                moving.addChild(platform2)
            case 481...568: // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 57 + randomAddedHeightDualSpawnPlatforms + 15) // -37 top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 461 + randomAddedHeightDualSpawnPlatforms) // 555 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 57 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 461 - randomAddedHeightDualSpawnPlatforms - 15)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + randomAddedHeightDualSpawnPlatforms + 15) // -7 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 491 + randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 87 - randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 491 - randomAddedHeightDualSpawnPlatforms - 15) // 585 Bottom of topplatform
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 128 + randomAddedHeightDualSpawnPlatforms + 15) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 530 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 128 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 530 - randomAddedHeightDualSpawnPlatforms - 15) // 624 bottom of topplatform
                }
                moving.addChild(platform2)
            }
            
        case 2: // Two platforms spawn a little apart from eachother
            switch screenWidth {
            case 0...480: // Iphone 4
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 33 + randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 340 + randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 33 - randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 340 - randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                }
                moving.addChild(platform2)
            case 481...568: // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down 57
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 107 + randomAddedHeightDualSpawnPlatforms) // -37 top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 411 + randomAddedHeightDualSpawnPlatforms) // 555 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 107 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 411 - randomAddedHeightDualSpawnPlatforms)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 137 + randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 441 + randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 137 - randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 441 - randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 178 + randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 480 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 178 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 480 - randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                }
                moving.addChild(platform2)
            }
            
        case 3: // Spawn a single platform that moves up/down
            switch screenWidth {
            case 0...480: // Iphone 4
                platform.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            case 481...568: // Iphone 5
                platform.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                platform.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            default: // Iphone 6 plus
                platform.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + baseAddedHeightSingleSpawn)
                moving.addChild(platform2)
            }
        default:
            break
        }
        
        // Setup platform and add to scene
        platform.zPosition = 2
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.collisionBitMask = playerCategory
        platform.physicsBody?.contactTestBitMask = playerCategory
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.restitution = 0.0
        platform.physicsBody?.affectedByGravity = false
        platform.name = "platformNode"
        moving.addChild(platform)
        
        // Setup scoreNode for scorekeeping
        scoreNode.position = CGPoint(x: self.frame.size.width + (platform.size.width * 6), y: self.frame.midY)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: self.frame.height))
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = playerCategory
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.zPosition = 1
        scoreNode.name = "scoreNode"
        moving.addChild(scoreNode)
        
        // Platform moving time
        let moveDuration = TimeInterval(frameWidth * 0.0070)
        
        // Move platform, platform2, scoreNode and remove from scene
        let movePlatform = SKAction.moveBy(x: -frameWidth - platformSmall1.size().width * 2 - 85, y: 0, duration: moveDuration )
        let removePlatform = SKAction.removeFromParent()
        let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
        
        platform.run(movePlatformAndRemove)
        delay(0.1){
            platformSpawned = false
        }
        if newLocation == 1 || newLocation == 2 { // Only apply action to platform2 if being used
            platform2.run(movePlatformAndRemove)
        }
        scoreNode.run(movePlatformAndRemove)
    }
    
    func setSpawnedToFalse() {
        platformSpawned = false
    }
    
    func spawnCoins() {
        
       // if (platformSpawned == false && coinSpawned == false)
         if (coinSpawned == false) {
            
            // Setting up coins
            coin = SKSpriteNode(texture: coinTexture)
            coin.texture = SKTexture(imageNamed: "Coin")
            coin.zPosition = 2
            coin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coin.size.width, height: coin.size.height))
            coin.physicsBody?.isDynamic = false
            coin.physicsBody?.categoryBitMask = coinCategory
            coin.physicsBody?.collisionBitMask = playerCategory
            coin.physicsBody?.contactTestBitMask = playerCategory
            coin.physicsBody?.allowsRotation = false
            coin.physicsBody?.restitution = 0.0
            coin.physicsBody?.affectedByGravity = false
            coin.name = "coinNode"
            
            let screenWidth = self.screenSize.height
        //    let determineCoinSpawn = arc4random_uniform(6)
            let coinSpawnLocation = arc4random_uniform(4)
            var coinMovement = arc4random_uniform(2)
            
       /*     switch determineCoinSpawn {
            case 0...1:
                break
            case 2...5: */
                switch coinSpawnLocation {
                case 0:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.18)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.27)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.27)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.29)
                    }
                case 1:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.30)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.35)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.37)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.36)
                    }
                case 2:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.50)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.53)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.50)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.54)
                    }
                case 3:
                    switch screenWidth {
                    case 0...480:
                        // iPhone 4
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.61)
                    case 481...568:
                        // iPhone 5
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.64)
                    case 569...667:
                        // iPhone 6
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.59)
                    default:
                        // iPhone 6 plus
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.61)
                    }
                default:
                    break
                }
                
         /*   default:
                break
            } */
            
            if (platformSpawned == true) {
                coin.position =  CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.99)
                coinMovement = 0
            }
            
            coins.addChild(coin)
            delayCoinSpawn()
            // Platform moving time
            // let moveDuration = NSTimeInterval(self.frame.size.width * 0.0055) // default 0.0055
            let moveDuration = TimeInterval(self.frame.size.width * 0.0070)
            
            // Move platform, platform2, scoreNode and remove from scene
            let movePlatform = SKAction.moveBy(x: -self.frame.size.width - platformSmall1.size().width * 2 - 85, y: 0, duration: moveDuration )
            let removePlatform = SKAction.removeFromParent()
            let movePlatformAndRemove = SKAction.sequence([movePlatform, removePlatform])
            let moveCoinUp = SKAction.moveBy(x: 0, y: 350, duration: 5.0)
            let moveCoinDown = SKAction.moveBy(x: 0, y: -350, duration: 5.0)
            switch coinMovement {
            case 0:
                break
            case 1:
                if (coinSpawnLocation == 0) {
                    coin.run(moveCoinUp)
                } else if (coinSpawnLocation == 1) {
                    coin.run(moveCoinUp)
                } else if (coinSpawnLocation == 3) {
                    coin.run(moveCoinDown)
                } else {
                    coin.run(moveCoinDown)
                }
            default:
                break
            }
            
            coin.run(movePlatformAndRemove)
        }
 
    }
    
    func delayCoinSpawn() {
        coinSpawned = true
        delay(2.0) {
            coinSpawned = false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if isAlive { // Check if player is alive, otherwise do nothing
            if (contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory){
                score += 1 // Increment score && update scoreLabel text
                scoreLabel.text = "\(score)"
                
            } else if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == coinCategory || contact.bodyA.categoryBitMask == coinCategory && contact.bodyB.categoryBitMask == playerCategory) {
                score += 5 // Increments score by 5 and makes the coin disappear
                coinSoundPlayer.play()
                // Animates the coin disappearing and  delays adding the coin back to the moving node, so the same coin you collected won't show up again
                coin.run(fadeOut, completion: addCoinToParent)
                scoreLabel.text = "\(score)" // Update scoreLabels text
            }   else if (contact.bodyA.categoryBitMask == platformCategory || contact.bodyB.categoryBitMask == platformCategory) {
                // Player has died, stop the game && stop spawning platforms
                self.removeAction(forKey: "platformSpawn")
                self.removeAction(forKey: "coinSpawn")
                isAlive = false
                moving.speed = 0
                scoreLabel.removeFromParent()
                
                if (backgroundMusicPlayer.isPlaying) {
                    backgroundMusicPlayer.stop()
                }
                if (muted == false) {
                    hitSoundPlayer.play()
                }
                coins.removeFromParent()
                // Jump back a bit after colliding
                player.physicsBody?.applyImpulse(CGVector(dx: -15, dy: 30))
                self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.5)
                
                // If current score is higher than highscore stored in device memory then set highscore as current score
                if (score > highscore) {
                    highscore = score
                    userSettingsDefaults.set(highscore, forKey: "Highscore")
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
                gameOverLabel.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
                gameOverLabel.textColor = UIColor.white
                gameOverLabel.layer.zPosition = 2
                gameOverLabel.textAlignment = NSTextAlignment.center
                
                // Create a play again button called restartGameButton
                restartGameButton = UIButton(type: UIButtonType.custom)
                restartGameButton.setImage(restartGameButtonImage, for: UIControlState())
                restartGameButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                restartGameButton.layer.zPosition = 2
                restartGameButton.addTarget(self, action: #selector(GameScene.restartGameButtonAction(_:)), for: UIControlEvents.touchUpInside)
                
                // Create a backToMainMenuButton to go back to menu
                backToMainMenuButton = UIButton(type: UIButtonType.custom)
                backToMainMenuButton.setImage(restartGameButtonImage, for: UIControlState())
                backToMainMenuButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                backToMainMenuButton.layer.zPosition = 2
                backToMainMenuButton.addTarget(self, action: #selector(GameScene.backToMainMenuButtonAction(_:)), for: UIControlEvents.touchUpInside)
                
                // muteButton Setup
                muteButton = UIButton(type: UIButtonType.custom) as UIButton!
                if (muted == false) {
                    muteButton.setImage(unmutedImage, for: UIControlState())
                } else {
                    muteButton.setImage(mutedImage, for: UIControlState())
                }
                muteButton.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
                muteButton.layer.zPosition = 5
                muteButton.addTarget(self, action: #selector(GameScene.muteAudio(_:)), for: UIControlEvents.touchUpInside)
                
                // Access the current screen width
                let screenWidth = self.screenSize.height
                
                // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 125, y: 100, width: 250, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.8, width: 80, height: 80)
                case 481...568:
                    // Iphone 5
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 125, y: 140, width: 250, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.8, width: 80, height: 80)
                case 569...667:
                    // Iphone 6
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 125, y: 210, width: 250, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.85, width: 80, height: 80)
                default:
                    // Iphone 6 plus
                    gameOverLabel.font = UIFont(name: "Avenir Next", size: 45)
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 175, y: 210, width: 350, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.85, width: 80, height: 80)
                }
                
                // Locations configured, add to view
                self.view!.addSubview(gameOverLabel)
                self.view!.addSubview(backToMainMenuButton)
                self.view!.addSubview(restartGameButton)
                self.view!.addSubview(muteButton)
                
                self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.5)
                
                // Animate the buttons
                UIView.animate(withDuration: 0.5, animations: {
                    restartGameButton.layer.position.x =  self.frame.size.width - self.frame.size.width * 0.3
                    backToMainMenuButton.layer.position.x = self.frame.size.width - self.frame.size.width * 0.7
                    muteButton.layer.position.x = self.frame.size.width - self.frame.size.width * 0.7
                })
            }
            
        }
    }
    
    func addCoinToParent() {
        coins.enumerateChildNodes(withName: "scoreNode") {
            node, stop in
            node.removeFromParent()
        }
  /*  delay(1.0) {
        moving.addChild(coins)
    } */
    }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if isAlive && stuffInTheScene { // Check if player is alive & game has started
            // Check swipe direction to change gravity direction (Up / Down)
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.up: // Swipe up
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 6.5)
                    player.startFlyingUp()
                case UISwipeGestureRecognizerDirection.down: // Swipe down
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.5)
                    player.startFlyingDown()
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
    
    func muteAudio(_ sender: UIButton!) {
        if (muted == false) {
            muted = true
            userSettingsDefaults.set(muted, forKey: "Muted")
            muteButton.setImage(mutedImage, for: UIControlState())
        } else {
            muted = false
            userSettingsDefaults.set(muted, forKey: "Muted")
            muteButton.setImage(unmutedImage, for: UIControlState())
        }
    }
    
    func restartGameButtonAction(_ sender: UIButton) {
        // Animate UIButton and UILabel
        UIView.animate(withDuration: 0.5, animations: {
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
    
    func backToMainMenuButtonAction(_ sender: UIButton) {
        // Animate UIButton and UILabel
        UIView.animate(withDuration: 0.5, animations: {
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
    
    func restart(_ ButtonType: String) {
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
        let transition = SKTransition.fade(with: backgroundColor, duration: 1.0)
        transition.pausesOutgoingScene = false
        
        // scene
        var scene: SKScene!
        if ButtonType == "RestartGame" {
            player.physicsBody?.isDynamic = false
            score = 0
            self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.5)
            player.position = CGPoint(x: self.frame.size.width / 2.8, y: self.frame.size.height * 0.5 - 50)
            moving.enumerateChildNodes(withName: "platformNode") {
                node, stop in
                node.removeFromParent()
            }
            moving.enumerateChildNodes(withName: "platform2Node") {
                node, stop in
                node.removeFromParent()
            }
            moving.enumerateChildNodes(withName: "scoreNode") {
                node, stop in
                node.removeFromParent()
            }
            coins.enumerateChildNodes(withName: "coinNode") {
                node, stop in
                node.removeFromParent()
            }
            coins.removeFromParent()
            scoreLabel.text = "\(score)"
            moving.addChild(scoreLabel)
            isAlive = true
            moving.speed = 1
            backgroundMusicPlayer.play()
            player.physicsBody?.isDynamic = true
            moving.addChild(coins)
            self.startSpawningPlatforms()
          /*  scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill */
        } else if ButtonType == "BackToMenu" {
            self.removeAllChildren()
            self.removeAllActions()
            self.removeFromParent()
            scene = MainMenuScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene, transition: transition)

        }
        
        // Present new scene with transition effect
      //  skView.presentScene(scene, transition: transition)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func delay(_ delay: Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
