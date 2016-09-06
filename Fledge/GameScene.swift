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
    
    var player: Player!
    var movingBottomPlatform: BottomPlatform!
    var movingTopPlatform: TopPlatform!
    var movingTopMountains: Mountains!
    var movingTopMountainsBackground: MountainsBackground!
    var movingTopBackground: Background!
    var movingBottomGround: Bottomground!
    
    var isAlive = true
    var restartGameButton = UIButton()
    var backToMainMenuButton = UIButton()
    let restartGameButtonImage = UIImage(named: "playButtonImage") as UIImage!
    var muteButton = UIButton()
    let mutedImage = UIImage(named: "Muted") as UIImage!
    let unmutedImage = UIImage(named: "Unmuted") as UIImage!
    var gameOverLabel = UILabel()
    
    var coin = SKSpriteNode()
    
    let topMountainsTexture = SKTexture(imageNamed: "TopMountainsFront")
    let topMountainsTextureIphone6 = SKTexture(imageNamed: "TopMountainsIphone6")
    let topMountainsBackgroundTexture = SKTexture(imageNamed: "TopMountainsBackground")
    let topMountainsBackgroundTextureIphone6 = SKTexture(imageNamed: "TopMountainsBackgroundIphone6")
    let backgroundTexture = SKTexture(imageNamed: "Background")
    let backgroundTextureIphone6 = SKTexture(imageNamed: "BackgroundIphone6")
    let TopPlatformTexture = SKTexture(imageNamed: "TopPlatform")
    let BottomPlatformTexture = SKTexture(imageNamed: "BottomPlatform")
    let platformSmall1 = SKTexture(imageNamed: "platformSmall2")
    let coinTexture = SKTexture(imageNamed: "Coin")
    let PlayerTexture1 = SKTexture(imageNamed: "Player")
    let tunnelTexture = SKTexture(imageNamed: "Tunnel")
    let bottomGroundTexture = SKTexture(imageNamed: "BottomGround")
    
    var stuffInTheScene = Bool()
    var platformSpawnTimer = NSTimer()
    var platformLocation = 0
    
    let playerCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let platformCategory: UInt32 = 1 << 4
    let scoreCategory: UInt32 = 1 << 5
    let coinCategory: UInt32 = 1 << 6
    
    var score = Int()
    var scoreLabel = SKLabelNode()
    
    var skyColor = UIColor(red: 133.0/255.0, green: 197.0/255.0, blue: 207.0/255.0, alpha: 1.0)
    let moving = SKNode()
    let topPlatform = SKNode()
    let bottomPlatform = SKNode()
    let topMountainsNode = SKNode()
    let topBackgroundNode = SKNode()
    let platforms = SKNode()
    let coins = SKNode()
    
    let userSettingsDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var highscore = Int()
    var spawnLocation = 0
    
    var platformSpawned = Bool()
    var coinSpawned = Bool()
    var muted = Bool()
    var newHighscore = Bool()
    
    var backgroundMusicPlayer = AVAudioPlayer()
    let backgroundMusic = NSBundle.mainBundle().pathForResource("background_music", ofType: "wav")
    
    var hitSoundPlayer = AVAudioPlayer()
    let hitSound = NSBundle.mainBundle().pathForResource("hit_sound_bestest", ofType: "wav")
    
    // Screen size detection
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func didMoveToView(view: SKView) {
        
        stuffInTheScene = false
        isAlive = true
        
        // Background color
        backgroundColor = skyColor
        
        // Physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -1.5)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.speed = 1
        
        // Moving & platforms node
        self.addChild(moving)
        moving.addChild(platforms)
        
        
        // Swipe up and down gesture recognizers
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view!.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view!.addGestureRecognizer(swipeDown)
        
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
        // No bottom ground texture for iphone 4 - doesnt fit in screen
        if screenHeight > 480 {
            movingBottomGround = Bottomground(size: CGSizeMake(bottomGroundTexture.size().width, bottomGroundTexture.size().height))
            moving.addChild(movingBottomGround)
        }
        
        moving.addChild(movingBottomPlatform)
        moving.addChild(movingTopPlatform)
        moving.addChild(movingTopMountains)
        moving.addChild(movingTopMountainsBackground)
        moving.addChild(movingTopBackground)
        
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
        
        // Background sprites (tunnel and bottomground)
        let tunnel = SKSpriteNode(texture: tunnelTexture)
        tunnel.zPosition = 1
        tunnel.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        // highscore & Scorelabel setup
        highscore = userSettingsDefaults.integerForKey("Highscore")
        
        // Checking whether audio is muted or not
        muted = userSettingsDefaults.boolForKey("Muted")
        
        score = 0
        scoreLabel.fontName = "Avenir Next"
        scoreLabel.fontColor = UIColor.whiteColor()
        scoreLabel.zPosition = 1
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
            scoreLabel.fontSize = 35 // Smaller font for score
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
        
        //Device height checked, add everything to scene
        moving.addChild(bottomPlatform)
        moving.addChild(topPlatform)
        moving.addChild(coins)
        moving.addChild(tunnel)
        moving.addChild(scoreLabel)
        moving.addChild(player)
        moving.speed = 1
        
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
        
        if stuffInTheScene == false {
            // Add things to scene and start the game
            addToScene()
            startSpawningPlatforms()
            if (muted == false) {
                backgroundMusicPlayer.play()
            }
            stuffInTheScene = true
        }
    }
    
    // Call splawnPlatforms function nth second
    func startSpawningPlatforms() {
        // platformSpawnTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(GameScene.spawnPlatforms), userInfo: nil, repeats: true)
        let actionwait = SKAction.waitForDuration(1.55)
        let actionrun = SKAction.runBlock({
            self.spawnPlatforms()
        })
        
        let coinWait = SKAction.waitForDuration(5.425)
        let coinRun = SKAction.runBlock({
            //self.spawnCoins()
        })
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([actionwait,actionrun])))
        //self.runAction(SKAction.repeatActionForever(SKAction.sequence([coinWait,coinRun])))
        
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
    
    func spawnPlatforms() {
        
        platformSpawned = true
        
        //Platform setup
        let platform = SKSpriteNode(texture: platformSmall1)
        let platform2 = SKSpriteNode(texture: platformSmall1)
        let scoreNode = SKSpriteNode()
        
        // Access the current screen width
        let screenWidth = self.screenSize.height
        
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
        }
        
        let randomAddedHeight =  CGFloat(arc4random_uniform(25))
        let baseAddedHeightSingleSpawn : CGFloat = 100 + randomAddedHeight
        let randomAddedHeightDualSpawnPlatforms = CGFloat(arc4random_uniform(65))
        let coinFlip = arc4random_uniform(2) // For double spawns - gap up or down
        
        //Check newlocation and setup platform locations
        switch newLocation {
            
        case 0: // Setup single platform spawn location
            
            let platformUpOrDown = Int(arc4random_uniform(2))
            
            if platformUpOrDown == 0 { // single bottom spawn
                
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, -23 + baseAddedHeightSingleSpawn)
                case 481...568:
                    // Iphone 5
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 57 + baseAddedHeightSingleSpawn)
                case 569...667:
                    // Iphone 6
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                default:
                    // Iphone 6 plus
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 128 + baseAddedHeightSingleSpawn)
                }
            } else if platformUpOrDown == 1 { // Single top spawn
                
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 390 - baseAddedHeightSingleSpawn)
                case 481...568:
                    // Iphone 5
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 461 - baseAddedHeightSingleSpawn)
                case 569...667:
                    // Iphone 6
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 491 - baseAddedHeightSingleSpawn)
                default:
                    // Iphone 6 plus
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 530 - baseAddedHeightSingleSpawn)
                }
            }
        case 1: // Setup Double platform spawn (Up and down)
            // redefine frameWith and replace it => let frameWidth = self.frame.size.width;
            switch screenWidth {
            case 0...480:
                // Iphone 4
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, -23 + randomAddedHeightDualSpawnPlatforms + 15)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 390 + randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, -23 - randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 390 - randomAddedHeightDualSpawnPlatforms - 15) // 475 Bottom of topplatform 94 difference
                }
                platforms.addChild(platform2)
            case 481...568:
                // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 57 + randomAddedHeightDualSpawnPlatforms + 15) // -37 top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 461 + randomAddedHeightDualSpawnPlatforms) // 555 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 57 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 461 - randomAddedHeightDualSpawnPlatforms - 15)
                }
                platforms.addChild(platform2)
            case 569...667:
                // Iphone 6
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 87 + randomAddedHeightDualSpawnPlatforms + 15) // -7 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 491 + randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 87 - randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 491 - randomAddedHeightDualSpawnPlatforms - 15) // 585 Bottom of topplatform
                }
                platforms.addChild(platform2)
            default:
                // Iphone 6 plus
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 128 + randomAddedHeightDualSpawnPlatforms + 15) // 34 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 530 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 128 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 530 - randomAddedHeightDualSpawnPlatforms - 15) // 624 bottom of topplatform
                }
                platforms.addChild(platform2)
            }
            
        case 2: // Two platforms spawn a little apart from eachother
            switch screenWidth {
            case 0...480:
                // Iphone 4
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 33 + randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 340 + randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 33 - randomAddedHeightDualSpawnPlatforms)  //-15  -108 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 340 - randomAddedHeightDualSpawnPlatforms) // 475 Bottom of topplatform 94 difference
                }
                platforms.addChild(platform2)
            case 481...568:
                // Iphone 5
                if coinFlip == 0 { // Centered gap  +15 to up/down 57
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 107 + randomAddedHeightDualSpawnPlatforms) // -37 top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 411 + randomAddedHeightDualSpawnPlatforms) // 555 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 107 - randomAddedHeightDualSpawnPlatforms)
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 411 - randomAddedHeightDualSpawnPlatforms)
                }
                platforms.addChild(platform2)
            case 569...667:
                // Iphone 6
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 137 + randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 441 + randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 137 - randomAddedHeightDualSpawnPlatforms) // -7 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 441 - randomAddedHeightDualSpawnPlatforms) // 585 Bottom of topplatform
                }
                platforms.addChild(platform2)
            default:
                // Iphone 6 plus
                if coinFlip == 0 { // Centered gap  +15 to up/down
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width, 178 + randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 480 + randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                } else { // other gap
                    platform2.position = CGPointMake(self.frame.size.width + platform.size.width + 85, 178 - randomAddedHeightDualSpawnPlatforms) // 34 Top of bottomplatform
                    platform.position = CGPointMake(self.frame.size.width + platform.size.width, 480 - randomAddedHeightDualSpawnPlatforms) // 624 bottom of topplatform
                }
                platforms.addChild(platform2)
            }
            
        case 3: // Spawn a single platform that moves up/down
            switch screenWidth {
            case 0...480:
                // Iphone 4
                platform.position = CGPointMake(self.frame.size.width + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                platforms.addChild(platform2)
            case 481...568:
                // Iphone 5
                platform.position = CGPointMake(self.frame.size.width + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                platforms.addChild(platform2)
            case 569...667:
                // Iphone 6
                platform.position = CGPointMake(self.frame.size.width + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                platforms.addChild(platform2)
            default:
                // Iphone 6 plus
                platform.position = CGPointMake(self.frame.size.width + platform.size.width, 87 + baseAddedHeightSingleSpawn)
                platforms.addChild(platform2)
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
        platforms.addChild(platform)
        
        // Setup scoreNode for scorekeeping
        scoreNode.position = CGPointMake(self.frame.size.width + (platform.size.width * 6), CGRectGetMidY(self.frame))
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(1, self.frame.height))
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = scoreCategory
        scoreNode.physicsBody?.contactTestBitMask = playerCategory
        scoreNode.physicsBody?.affectedByGravity = false
        platforms.addChild(scoreNode)
        
        // Platform moving time
        let moveDuration = NSTimeInterval(self.frame.size.width * 0.0070)
        
        // Move platform, platform2, scoreNode and remove from scene
        let movePlatform = SKAction.moveByX(-self.frame.size.width - platformSmall1.size().width * 2 - 85, y: 0, duration: moveDuration )
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
    
    func spawnCoins() {
        /*
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
            
            coins.addChild(coin)
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
 */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if isAlive { // Check if player is alive, otherwise do nothing
            
            if (contact.bodyA.categoryBitMask == scoreCategory || contact.bodyB.categoryBitMask == scoreCategory){
                // Increment score
                score += 1
                // Update scoreLabels text
                scoreLabel.text = "\(score)"
            } else if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == coinCategory || contact.bodyA.categoryBitMask == coinCategory && contact.bodyB.categoryBitMask == playerCategory) {
                // Increments score by 5 and makes the coin disappear
                score += 5
                coins.removeFromParent()
                addCoinToParent()
                // Update scoreLabels text
                scoreLabel.text = "\(score)"
            } else if (contact.bodyA.categoryBitMask == platformCategory || contact.bodyB.categoryBitMask == platformCategory) {
                // Player has died, stop the game
                // Stop spawning platforms
                isAlive = false
                scoreLabel.removeFromParent()
                moving.speed = 0
                
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
                
                // Add gameover label + back to menu and restart button
                // Gameover label
                if (newHighscore) {
                    self.gameOverLabel.text = "New highscore! \n \(score)"
                    self.gameOverLabel.font = UIFont(name: "Avenir Next", size: 34)
                } else {
                    self.gameOverLabel.text = "Score: \(score)"
                    self.gameOverLabel.font = UIFont(name: "Avenir Next", size: 40)
                }
                self.gameOverLabel.numberOfLines = 0
                self.gameOverLabel.layer.anchorPoint = CGPointMake(1.0, 1.0)
                self.gameOverLabel.textColor = UIColor.whiteColor()
                self.gameOverLabel.layer.zPosition = 2
                self.gameOverLabel.textAlignment = NSTextAlignment.Center
                
                // Create a play again button called restartGameButton
                self.restartGameButton = UIButton(type: UIButtonType.Custom)
                self.restartGameButton.setImage(self.restartGameButtonImage, forState: .Normal)
                self.restartGameButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
                self.restartGameButton.layer.zPosition = 2
                // Make the button perform an action when it is pressed
                self.restartGameButton.addTarget(self, action: #selector(GameScene.restartGameButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                // Create a backToMainMenuButton to go back to menu
                self.backToMainMenuButton = UIButton(type: UIButtonType.Custom)
                self.backToMainMenuButton.setImage(self.restartGameButtonImage, forState: .Normal)
                self.backToMainMenuButton.layer.anchorPoint = CGPointMake(0.5, 0.5)
                self.backToMainMenuButton.layer.zPosition = 2
                // Make the button perform an action when it is pressed
                self.backToMainMenuButton.addTarget(self, action: #selector(GameScene.backToMainMenuButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                // muteButton Setup
                self.muteButton = UIButton(type: UIButtonType.Custom) as UIButton!
                if (muted == false) {
                    self.muteButton.setImage(unmutedImage, forState: .Normal)
                } else {
                    self.muteButton.setImage(mutedImage, forState: .Normal)
                }
                // muteButton,frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height * 0.65, 80, 80)
                self.muteButton.layer.anchorPoint = CGPointMake(1.0, 1.0)
                self.muteButton.layer.zPosition = 5
                self.muteButton.addTarget(self, action: #selector(GameScene.muteAudio(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                // Access the current screen width
                let screenWidth = self.screenSize.height
                
                // ADD EVERYTHING DEFINED ABOVE TO THE CORRECT POSITION DEPENDING ON DEVICE HEIGHT (POINTS)
                switch screenWidth {
                case 0...480:
                    // Iphone 4
                    self.gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 125, 100, 250, 200)
                    self.backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    self.restartGameButton.frame = CGRectMake(self.restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    self.muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.8, 80, 80)
                case 481...568:
                    // Iphone 5
                    self.gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 125, 140, 250, 200)
                    self.backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    self.restartGameButton.frame = CGRectMake(self.restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    self.muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.8, 80, 80)
                case 569...667:
                    // Iphone 6
                    self.gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 125, 210, 250, 200)
                    self.backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    self.restartGameButton.frame = CGRectMake(self.restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    self.muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.85, 80, 80)
                default:
                    // Iphone 6 plus
                    self.gameOverLabel.font = UIFont(name: "Avenir Next", size: 45)
                    self.gameOverLabel.frame = CGRectMake(self.frame.size.width * 0.5 - 175, 210, 350, 200)
                    self.backToMainMenuButton.frame = CGRectMake(-80, self.frame.size.height * 0.6, 80, 80)
                    self.restartGameButton.frame = CGRectMake(self.restartGameButton.frame.size.width + self.frame.size.width, self.frame.size.height * 0.6, 80, 80)
                    self.muteButton.frame = CGRectMake(-80, self.frame.size.height * 0.85, 80, 80)
                }
                
                // Locations configured, add to view
                self.view!.addSubview(self.gameOverLabel)
                self.view!.addSubview(self.backToMainMenuButton)
                self.view!.addSubview(self.restartGameButton)
                self.view!.addSubview(self.muteButton)
                
                // Animate the buttons
                UIView.animateWithDuration(0.5, animations: {
                    self.restartGameButton.layer.position.x =  self.frame.size.width - self.frame.size.width * 0.3
                    self.backToMainMenuButton.layer.position.x = self.frame.size.width - self.frame.size.width * 0.7
                    self.muteButton.layer.position.x = self.frame.size.width - self.frame.size.width * 0.7
                })
            }
            
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        // Check if player is alive & game has started
        if isAlive && stuffInTheScene {
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
            if screenHeight > 480 {
                movingBottomGround.begin() // for iPhone 4s - dont add movingBottomGround
            }
            player.startFlying()
        }
    }
    
    func addCoinToParent() {
        delay(1.0) {
            //self.moving.addChild(self.coins)
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
            self.restartGameButton.layer.position.x = self.frame.size.width + self.restartGameButton.frame.size.width
            self.backToMainMenuButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
            self.muteButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
        })
        
        // Call restart function after 0.5s delay
        delay(0.5) {
            self.restart("RestartGame")
            
        }
    }
    
    func backToMainMenuButtonAction(sender: UIButton) {
        // Animate UIButton and UILabel
        UIView.animateWithDuration(0.5, animations: {
            self.restartGameButton.layer.position.x = self.frame.size.width + self.restartGameButton.frame.size.width
            self.backToMainMenuButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
            self.muteButton.layer.position.x -= self.frame.size.width - self.frame.size.width / 2
        })
        
        // Call restart function after 0.5s delay
        delay(0.5) {
            self.restart("BackToMenu")
        }
    }
    
    func restart(ButtonType: String) {
        // Restart the game
        // Remove labels and buttons
        self.restartGameButton.removeFromSuperview()
        self.gameOverLabel.removeFromSuperview()
        self.backToMainMenuButton.removeFromSuperview()
        self.muteButton.removeFromSuperview()
        self.removeAllActions()
        self.removeAllChildren()
        self.removeFromParent()
        
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
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
        } else if ButtonType == "BackToMenu" {
            scene = MainMenuScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
        }
        
        // Present new scene with transition effect
        skView.presentScene(scene, transition: transition)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func delay(delay: Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
}
