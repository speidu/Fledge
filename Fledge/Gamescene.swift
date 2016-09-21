//
//  GameScene.swift
//
//
//  Created by Teemu on 13.2.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.main.bounds
    
    override func didMove(to view: SKView) {
        stuffInTheScene = false
        isAlive = true
        notFirstTime = userSettingsDefaults.bool(forKey: "NotFirstTime")
        platformLocation = 2 // Force variable gap as first obstacle
        
        // Background color
        let tunnelBackgroundColor = UIColor.init(red: 0.483, green: 0.483, blue: 0.483, alpha: 1.0)
        backgroundColor = tunnelBackgroundColor
        
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
        bottomPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: BottomPlatformTexture.size().height * 0.75))
        bottomPlatform.physicsBody?.isDynamic = false
        bottomPlatform.physicsBody?.categoryBitMask = platformCategory
        bottomPlatform.physicsBody?.collisionBitMask = playerCategory
        bottomPlatform.physicsBody?.contactTestBitMask = playerCategory
        bottomPlatform.physicsBody?.restitution = 0.0
        bottomPlatform.physicsBody?.affectedByGravity = false
        
        // TopPlatform properties
        topPlatform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: TopPlatformTexture.size().height * 0.75))
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
        if (notFirstTime == true) {
            player.physicsBody?.isDynamic = true
        } else {
            player.physicsBody?.isDynamic = false
        }
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0.0
        player.name = "playerNode"
        
        // Moving & platforms node
        addChild(moving)
        addChild(tutorials)
        
        // Call an instance of Top, Bottomplatform, Bottomground, Mountains and Background classes
        let screenHeight = self.screenSize.height
        
        switch screenHeight { // For moving top sprites
            case 569...667: // Setup moving top background sprites for iphone 6 size
                movingTopBackground = Background(size: CGSize(width: backgroundTextureIphone6.size().width, height: backgroundTextureIphone6.size().height))
                movingTopMountains = Mountains(size: CGSize(width: topMountainsTextureIphone6.size().width, height: topMountainsTextureIphone6.size().height))
                movingTopMountainsBackground = MountainsBackground(size: CGSize(width: topMountainsBackgroundTextureIphone6.size().width, height: topMountainsBackgroundTextureIphone6.size().height))
                movingTunnelForeground = TunnelForeground(size: CGSize(width: tunnelForegroundTexture.size().width, height: tunnelForegroundTexture.size().height))
                movingTunnelMidground = TunnelMidground(size: CGSize(width: tunnelMidgroundTexture.size().width, height: tunnelMidgroundTexture.size().height))
            default:
                // Otherwise use defaults
                movingTopBackground = Background(size: CGSize(width: backgroundTexture.size().width, height: backgroundTexture.size().height))
                movingTopMountains = Mountains(size: CGSize(width: topMountainsTexture.size().width, height: topMountainsTexture.size().height))
                movingTopMountainsBackground = MountainsBackground(size: CGSize(width: topMountainsBackgroundTexture.size().width, height: topMountainsBackgroundTexture.size().height))
                movingTunnelForeground = TunnelForeground(size: CGSize(width: tunnelForegroundTexture.size().width, height: tunnelForegroundTexture.size().height))
                movingTunnelMidground = TunnelMidground(size: CGSize(width: tunnelMidgroundTexture.size().width, height: tunnelMidgroundTexture.size().height))
        }
        
        movingBottomPlatform = BottomPlatform(size: CGSize(width: BottomPlatformTexture.size().width, height: BottomPlatformTexture.size().height))
        movingTopPlatform = TopPlatform(size: CGSize(width: TopPlatformTexture.size().width, height: TopPlatformTexture.size().height))
        movingBottomGround = Bottomground(size: CGSize(width: bottomGroundTexture.size().width, height: bottomGroundTexture.size().height))
        
        moving.addChild(movingBottomGround)
        moving.addChild(movingBottomPlatform)
        moving.addChild(movingTopPlatform)
        moving.addChild(movingTopMountains)
        moving.addChild(movingTopMountainsBackground)
        moving.addChild(movingTopBackground)
        moving.addChild(movingTunnelForeground)
        moving.addChild(movingTunnelMidground)
        
        // highscore & Scorelabel setup
        highscore = userSettingsDefaults.integer(forKey: "Highscore")
        
        score = 0
        scoreLabel.fontName = "VCROSDMono"
        scoreLabel.fontColor = UIColor.white
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 45
        scoreLabel.zPosition = 4
        
        // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
        switch screenHeight {
        case 0...568:
            // Iphone 5
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 438)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: 80)
            scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: 20)
        case 569...667:
            // Iphone 6
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 468)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: 110)
            scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: 35)
        default:
            // Iphone 6 plus
            topPlatform.position = CGPoint(x: self.frame.width / 2, y: 508)
            bottomPlatform.position = CGPoint(x: self.frame.width / 2, y: 150)
            scoreLabel.position = CGPoint(x: self.frame.size.width / 2, y: 50)
        }
        
        moving.addChild(bottomPlatform) //Device height checked, add everything to scene
        moving.addChild(topPlatform)
        moving.addChild(coins)
        moving.addChild(scoreLabel)
        
        if notFirstTime == false && stuffInTheScene == false{ // Setup how to play screen for first launch time
            showTutorialScreen()
            
        } else if stuffInTheScene == false { // Add things to scene and start the game
            self.addChild(player)
            moving.speed = 1
            addToScene()
            startSpawningPlatforms()
            beginPlayingBackgroundMusic()
            stuffInTheScene = true
        }
    }
    
    func showTutorialScreen() { // Setup how to play screen and show it
        moving.speed = 0
        
        // Black background for tutorial image
        blackScreen.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        blackScreen.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        blackScreen.alpha = 0.8
        blackScreen.color = UIColor.black
        blackScreen.zPosition = 8
        blackScreen.name = "BlackScreen"
        tutorials.addChild(blackScreen)
        
        tutorial = SKSpriteNode(imageNamed: "Tutorial") // Tutorial sprite
        tutorial.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        tutorial.zPosition = 8
        tutorial.name = "Tutorial"
        tutorials.addChild(tutorial)
        
        resumeGameButton = UIButton(type: UIButtonType.custom) // Resume the game button
        resumeGameButton.setImage(nextGameButtonImage, for: UIControlState())
        resumeGameButton.frame = CGRect(x: self.frame.width * 0.6, y: self.frame.height * 0.6, width: 80, height: 80)
        resumeGameButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        resumeGameButton.layer.zPosition = 9
        resumeGameButton.addTarget(self, action: #selector(GameScene.resumeGameButtonAction(_:)), for: UIControlEvents.touchUpInside)
        self.view!.addSubview(resumeGameButton)
    }
    
    func addToScene() { // Animate sprites
        if stuffInTheScene == false {
            movingBottomPlatform.begin()
            movingTopPlatform.begin()
            movingTopBackground.begin()
            movingTopMountains.begin()
            movingTopMountainsBackground.begin()
            movingTunnelForeground.begin()
            movingTunnelMidground.begin()
            player.startFlying()
            movingBottomGround.begin()
        }
    }
    
    func beginPlayingBackgroundMusic() { // Setup sound effects
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
        
        if (muted == false) {
            backgroundMusicPlayer.play()
        }
    }
    
    func startSpawningPlatforms() { // Call spawnPlatforms function every nth second
        let actionwait = SKAction.wait(forDuration: 1.55)
        let actionrun = SKAction.run({
            self.spawnPlatforms()
        })
        
        let coinWait = SKAction.wait(forDuration: 5.425) // 5.425 0.2
        let coinRun = SKAction.run({
            self.spawnCoins()
        })
        
        run(SKAction.repeatForever(SKAction.sequence([actionwait,actionrun])), withKey: "platformSpawn")
        run(SKAction.repeatForever(SKAction.sequence([coinWait,coinRun])), withKey: "coinSpawn")
    }
    
    //Determine platform spawn location
    func DeterminePlatformLocation(_ previousPlatformLocation: Int) -> Int {
        //Check previous platform location
        while spawnLocation == previousPlatformLocation { // Force different spawn every time
            spawnLocation = Int(arc4random_uniform(4))
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
        var platform2 = SKSpriteNode(texture: platformSmall1)
        let scoreNode = SKSpriteNode()
        
        // Access the current screen width
        let screenWidth = screenSize.height
        
        if coinSpawnedFirst {
        } else {
            newLocation = DeterminePlatformLocation(platformLocation)
            platformLocation = newLocation
            coinFlip = Int(arc4random_uniform(2)) // For double spawns - gap up or down
            platformUpOrDown = Int(arc4random_uniform(2))
        }
        
        if newLocation == 1 || newLocation == 2 || newLocation == 3 { // If more than 1 platform, setup platform2 properties
            
            if newLocation == 3 { // For spike obstacle spawn
                platform2 = SKSpriteNode(texture: spikeObstacleTexture)
                platform2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform2.size.width * 0.8, height: platform2.size.height * 0.8))
                platform2.zPosition = 3
            } else {
                platform2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
            }
                platform2.zPosition = 2
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
        let frameWidth = self.frame.size.width
        
        switch newLocation { //Check newlocation and setup platform locations
            
        case 0: // Setup single platform spawn location

            if platformUpOrDown == 0 { // single bottom spawn
                switch screenWidth {
                case 0...568: // Iphone 5
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 57 + baseAddedHeightSingleSpawn)
                case 569...667: // Iphone 6
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + baseAddedHeightSingleSpawn)
                default: // Iphone 6 plus
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 128 + baseAddedHeightSingleSpawn)
                }
            } else if platformUpOrDown == 1 { // Single top spawn
                switch screenWidth {
                case 0...568: // Iphone 5
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 461 - baseAddedHeightSingleSpawn)
                case 569...667: // Iphone 6
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 491 - baseAddedHeightSingleSpawn)
                default: // Iphone 6 plus
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 530 - baseAddedHeightSingleSpawn)
                }
            }
        case 1: // Setup Double platform spawn (Up and down)
            switch screenWidth {
            case 0...568: // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 57 + randomAddedHeightDualSpawnPlatforms + 15)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 461 + randomAddedHeightDualSpawnPlatforms)
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 57 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 461 - randomAddedHeightDualSpawnPlatforms - 15)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 87 + randomAddedHeightDualSpawnPlatforms + 15)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 491 + randomAddedHeightDualSpawnPlatforms)
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 87 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 491 - randomAddedHeightDualSpawnPlatforms - 15)
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 128 + randomAddedHeightDualSpawnPlatforms + 15) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 530 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 128 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 530 - randomAddedHeightDualSpawnPlatforms - 15) // 624 bottom of topplatform
                }
                moving.addChild(platform2)
            }
            
        case 2: // Two platforms spawn a little apart from eachother
            switch screenWidth {
            case 0...568: // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down 57
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 107 + randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 411 + randomAddedHeightDualSpawnPlatforms)
                } else { // other gap
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 107 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 411 - randomAddedHeightDualSpawnPlatforms)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 { //
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 137 + randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 441 + randomAddedHeightDualSpawnPlatforms)
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 137 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 441 - randomAddedHeightDualSpawnPlatforms)
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: 178 + randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 480 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width + 85, y: 178 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPoint(x: frameWidth + platform.size.width, y: 480 - randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                }
                moving.addChild(platform2)
            }
            
        case 3: // Spawn a single spike obstacle that moves up/down
            switch screenWidth {
            case 0...568: // Iphone 5
                if coinFlip == 0 { // coinFlip == 0 equals top spawn, otherwise bottom
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: self.frame.size.height * 0.67)
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: self.frame.size.height * 0.25)
                }
                moving.addChild(platform2)
            case 569...667: // Iphone 6
                if coinFlip == 0 {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: self.frame.size.height * 0.61)
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: self.frame.size.height * 0.30)
                }
                moving.addChild(platform2)
            default: // Iphone 6 plus
                if coinFlip == 0 {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: self.frame.size.height * 0.61)
                } else {
                    platform2.position = CGPoint(x: frameWidth + platform.size.width, y: self.frame.size.height * 0.30)
                }
                moving.addChild(platform2)
            }
        default:
            break
        }
        
        if newLocation != 3 { // Setup platform and add to scene
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
        }
        
        // Setup scoreNode for scorekeeping
        scoreNode.position = CGPoint(x: self.frame.size.width + (platform.size.width * 2), y: self.frame.midY)
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
        
        if newLocation == 1 || newLocation == 2 { // Only apply action to platform2 if being used
            platform2.run(movePlatformAndRemove)
            
        } else if newLocation == 3 { // For a moving spike platform spawn (Up/down)
            let movePlatformUp = SKAction.moveBy(x: 0, y: 200, duration: 2.5)
            let movePlatformDown = SKAction.moveBy(x: 0, y: -200, duration: 2.5)
            var movePlatformSequence = SKAction()
            if coinFlip == 0 {
                movePlatformSequence = SKAction.sequence([movePlatformDown, movePlatformUp])
            } else {
                movePlatformSequence = SKAction.sequence([movePlatformUp, movePlatformDown])
            }
            let rotatePlatform = SKAction.rotate(byAngle: 20, duration: 5)
            let moveGroup = SKAction.group([movePlatformAndRemove, movePlatformSequence, rotatePlatform])
            platform2.run(moveGroup)
        }
        
        platform.run(movePlatformAndRemove)
        scoreNode.run(movePlatformAndRemove)
        delay(0.1){
            platformSpawned = false
        }
    }
    
    func spawnCoins() { // Spawn a coin every nth second
        if (coinSpawned == false) {
            
            coinSpawnedFirst = true
            newLocation = DeterminePlatformLocation(platformLocation)
            platformLocation = newLocation
            coinFlip = Int(arc4random_uniform(2)) // For double spawns - gap up or down
            platformUpOrDown = Int(arc4random_uniform(2))
            
            delay(0.8) {
                coinSpawnedFirst = false
            }
            
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
            let coinSpawnLocation = Int(arc4random_uniform(2))
            let coinMovement = arc4random_uniform(2)
            let moveCoinUp = SKAction.moveBy(x: 0, y: 350, duration: 5.0)
            let moveCoinDown = SKAction.moveBy(x: 0, y: -350, duration: 5.0)
            
            switch newLocation { //Check newlocation and setup platform locations
                
            case 0: // Setup single platform spawn location
                
                if platformUpOrDown == 0 {
                    switch screenWidth {
                    case 0...568: // Iphone 5
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                            coin.run(moveCoinUp)
                        } else if coinSpawnLocation == 1{
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.64)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.49)
                        }
                    case 569...667: // Iphone 6
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.38)
                            coin.run(moveCoinUp)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.59)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.49)
                        }
                    default: // Iphone 6 plus
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.39)
                            coin.run(moveCoinUp)
                        } else if coinSpawnLocation == 1{
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.61)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.51)
                        }
                    }
                            coins.addChild(coin)
                } else if platformUpOrDown == 1 {
                    switch screenWidth {
                    case 0...568:
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.50)
                            coin.run(moveCoinDown)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.27)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                        }
                    case 569...667: // Iphone 6
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.50)
                            coin.run(moveCoinDown)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.27)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                        }
                    default: // Iphone 6 plus
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.52)
                            coin.run(moveCoinDown)
                        } else if coinSpawnLocation == 1{
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.29)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.39)
                        }
                    }
                            coins.addChild(coin)
                }
            case 1:
                switch screenWidth {
                case 0...568: // Iphone 5
                    if coinFlip == 0 {
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.37)
                    } else { // other gap
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.54)
                    }
                    coins.addChild(coin)
                case 569...667: // Iphone 6
                    if coinFlip == 0 {
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.37)
                    } else {
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.49)
                    }
                    coins.addChild(coin)
                default: // Iphone 6 plus
                    if coinFlip == 0 {
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.39)
                    } else {
                        coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.51)
                    }
                    coins.addChild(coin)
                }
                
            case 2:
                switch screenWidth {
                case 0...568: // Iphone 5
                    if coinFlip == 0 {
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                            coin.run(moveCoinUp)
                        } else if coinSpawnLocation == 1{
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.64)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.49)
                        }
                    } else { // other gap
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.50)
                            coin.run(moveCoinDown)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.27)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                        }
                    }
                    coins.addChild(coin)
                case 569...667: // Iphone 6
                    if coinFlip == 0 { //
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                            coin.run(moveCoinUp)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.59)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.49)
                        }
                    } else {
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.50)
                            coin.run(moveCoinDown)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.27)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.41)
                        }
                    }
                    coins.addChild(coin)
                default: // Iphone 6 plus
                    if coinFlip == 0 {
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.39)
                            coin.run(moveCoinUp)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.61)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.51)
                        }
                    } else {
                        if coinMovement == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.52)
                            coin.run(moveCoinDown)
                        } else if coinSpawnLocation == 1 {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.29)
                        } else {
                            coin.position = CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.39)
                        }
                    }
                    coins.addChild(coin)
                }
            default:
                break
            }
            
            
            if (platformSpawned == true) {
                coin.position =  CGPoint(x: self.frame.size.width + coin.frame.width, y: self.frame.size.height * 0.99)
                coins.enumerateChildNodes(withName: "coinNode") {
                    node, stop in
                    node.removeFromParent()
                }
            }
            
            delayCoinSpawn()
            // Platform moving time
            let moveDuration = TimeInterval(self.frame.size.width * 0.0070)
            // Move platform, platform2, scoreNode and remove from scene
            let movePlatform = SKAction.moveBy(x: -self.frame.size.width - platformSmall1.size().width * 2 - 85, y: 0, duration: moveDuration )
            //    let removePlatform = SKAction.removeFromParent()
            let removeCoin =  SKAction.run {
                coins.enumerateChildNodes(withName: "coinNode") {
                    node, stop in
                    node.removeFromParent()
                }
            }
            let movePlatformAndRemove = SKAction.sequence([movePlatform, removeCoin])
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
                
                if (muted == false) { //Check if game is Muted
                    coin.run(coinPickUpSound)
                }
                // Animates the coin disappearing and  delays adding the coin back to the moving node, so the same coin you collected won't show up again
                coin.run(fadeOut, completion: removeCoinFromParent)
                score += 5 // Increments score by 5 and makes the coin disappear
                scoreLabel.text = "\(score)" // Update scoreLabels text
                
            }   else if (contact.bodyA.categoryBitMask == platformCategory || contact.bodyB.categoryBitMask == platformCategory) {
                // Player has died, stop the game && stop spawning platforms
                isAlive = false
                moving.speed = 0
                scoreLabel.removeFromParent()
                player.stop()
                removeAction(forKey: "platformSpawn")
                removeAction(forKey: "coinSpawn")
                
                if (backgroundMusicPlayer.isPlaying) {
                    backgroundMusicPlayer.stop()
                }
                if (muted == false) {
                    player.run(hitSound2)
                }

                // Jump back a bit after colliding
                player.physicsBody?.applyImpulse(CGVector(dx: -10, dy: 10))
                self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.5)
                player.hasHitObstacle()
                
                // If current score is higher than highscore stored in device memory then set highscore as current score
                if (score > highscore) {
                    highscore = score
                    userSettingsDefaults.set(highscore, forKey: "Highscore")
                    newHighscore = true
                }
                
                if (newHighscore) { // Add gameover label + back to menu and restart button
                    gameOverLabel.text = "NEW HIGHSCORE! \n \n \(score)"
                    gameOverLabel.font = UIFont(name: "VCROSDMono", size: 30)
                    newHighscore = false
                } else {
                    gameOverLabel.text = "Score: \(score)"
                    gameOverLabel.font = UIFont(name: "VCROSDMono", size: 40)
                }
                gameOverLabel.numberOfLines = 0
                gameOverLabel.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
                gameOverLabel.textColor = UIColor.white
                gameOverLabel.layer.zPosition = 2
                gameOverLabel.textAlignment = NSTextAlignment.center
                gameOverLabel.alpha = 0.0
                
                // Create a play again button called restartGameButton
                restartGameButton = UIButton(type: UIButtonType.custom)
                restartGameButton.setImage(restartGameButtonImage, for: UIControlState())
                restartGameButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                restartGameButton.layer.zPosition = 2
                restartGameButton.addTarget(self, action: #selector(GameScene.restartGameButtonAction(_:)), for: UIControlEvents.touchUpInside)
                
                // Create a backToMainMenuButton to go back to menu
                backToMainMenuButton = UIButton(type: UIButtonType.custom)
                backToMainMenuButton.setImage(menuButtonImage, for: UIControlState())
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
                case 0...568:
                    // Iphone 5
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 125, y: 140, width: 250, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.8, width: 50, height: 50)
                case 569...667:
                    // Iphone 6
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 125, y: 210, width: 250, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.85, width: 50, height: 50)
                default:
                    // Iphone 6 plus
                    gameOverLabel.font = UIFont(name: "VCROSDMono", size: 40)
                    gameOverLabel.frame = CGRect(x: self.frame.size.width * 0.5 - 175, y: 210, width: 350, height: 200)
                    backToMainMenuButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    restartGameButton.frame = CGRect(x: restartGameButton.frame.size.width + self.frame.size.width, y: self.frame.size.height * 0.6, width: 80, height: 80)
                    muteButton.frame = CGRect(x: -80, y: self.frame.size.height * 0.85, width: 50, height: 50)
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
                    gameOverLabel.alpha = 1.0
                })
                
                delay(1.0) { // Show an ad
                    AdsUtility.chartboostInterstitial()
                }
            }
            
        }
    }
    
    func removeCoinFromParent() {
        coins.enumerateChildNodes(withName: "coinNode") {
            node, stop in
            node.removeFromParent()
        }
    }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if isAlive && stuffInTheScene { // Check if player is alive & game has started
            // Check swipe direction to change gravity direction (Up / Down)
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.up: // Swipe up
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 6.5)
                case UISwipeGestureRecognizerDirection.down: // Swipe down
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.5)
                default:
                    break
                }
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
            gameOverLabel.alpha = 0.0
        })
        
        // Call restart function after 0.5s delay
        delay(0.5) {
            self.restart("RestartGame")
        }
    }
    
    func backToMainMenuButtonAction(_ sender: UIButton) {
        // Animate UIButton and UILabel
        UIView.animate(withDuration: 0.5, animations: {
            restartGameButton.layer.position.x = self.frame.size.width + restartGameButton.frame.size.width
            backToMainMenuButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
            muteButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
            gameOverLabel.alpha = 0.0
        })
        
        // Call restart function after 0.5s delay
        delay(0.5) {
            platforms.removeAllChildren()
            platforms.removeAllChildren()
            platforms.removeFromParent()
            moving.removeAllChildren()
            moving.removeAllActions()
            moving.removeFromParent()
            self.removeAllChildren()
            self.removeAllActions()
            self.restart("BackToMenu")
        }
    }
    
    func resumeGameButtonAction(_ sender: UIButton) {
        tutorials.enumerateChildNodes(withName: "BlackScreen") {
            node, stop in
            node.removeFromParent()
        }
        tutorials.enumerateChildNodes(withName: "Tutorial") {
            node, stop in
            node.removeFromParent()
        }
        tutorials.removeFromParent()
        resumeGameButton.removeFromSuperview()
        self.addChild(player)
        moving.speed = 1
        addToScene()
        startSpawningPlatforms()
        beginPlayingBackgroundMusic()
        stuffInTheScene = true
        userSettingsDefaults.set(true, forKey: "NotFirstTime")
        delay(0.05) {
            player.physicsBody?.isDynamic = true
        }
    }
    
    func restart(_ ButtonType: String) {
        // Restart the game
        // Remove labels and buttons
        restartGameButton.removeFromSuperview()
        gameOverLabel.removeFromSuperview()
        backToMainMenuButton.removeFromSuperview()
        muteButton.removeFromSuperview()
        
        // scene
        var scene: SKScene!
        if ButtonType == "RestartGame" { // Reset everything to original positions
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
            
            isAlive = true
            player.physicsBody?.isDynamic = true
            scoreLabel.text = "\(score)"
            moving.addChild(scoreLabel)
            moving.addChild(coins)
            moving.speed = 1
            player.resetSprite()
            platforms.speed = 1
            self.startSpawningPlatforms() // Start the game again
            player.startFlying()
            if (muted == false) { // Continue the background music if not muted
                backgroundMusicPlayer.play()
            }

        } else if ButtonType == "BackToMenu" {
            // Setup transition to GameScene
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            
            // Remove current scene before transitioning
            self.scene?.removeFromParent()
            
            // Transition effect
            let transition = SKTransition.fade(with: UIColor(red: 133.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0), duration: 1.0)
            transition.pausesOutgoingScene = false
            
           coins.enumerateChildNodes(withName: "coinNode") {
                node, stop in
                node.removeFromParent()
            }
            self.removeAllChildren()
            self.removeAllActions()
            self.removeFromParent()
            scene = MainMenuScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene, transition: transition)

        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func delay(_ delay: Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
