//
//  Constants.swift
//  Fledge
//
//  Created by Pasi Särkilahti & Teemu Salminen on 6.9.2016.
//  Copyright © 2016 Pasi Särkilahti & Teemu Salminen. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

var player: Player!
var movingBottomPlatform: BottomPlatform!
var movingTopPlatform: TopPlatform!
var movingTopMountains: Mountains!
var movingTopMountainsBackground: MountainsBackground!
var movingTopBackground: Background!
var movingBottomGround: Bottomground!
var movingTunnelForeground: TunnelForeground!
var movingTunnelMidground: TunnelMidground!


var isAlive = true
var restartGameButton = UIButton()
var backToMainMenuButton = UIButton()
var resumeGameButton = UIButton()
let restartGameButtonImage = UIImage(named: "restartGameButton") as UIImage!
let nextGameButtonImage = UIImage(named: "NextButton") as UIImage!
let menuButtonImage = UIImage(named: "MenuButton") as UIImage!
var muteButton = UIButton()
let mutedImage = UIImage(named: "Muted") as UIImage!
let unmutedImage = UIImage(named: "Unmuted") as UIImage!
var gameOverLabel = UILabel()

var coin = SKSpriteNode()
var blackScreen = SKSpriteNode()
var tutorial = SKSpriteNode()

let topMountainsTexture = SKTexture(imageNamed: "TopMountainsFront")
let topMountainsTextureIphone6 = SKTexture(imageNamed: "TopMountainsIphone6")
let topMountainsBackgroundTexture = SKTexture(imageNamed: "TopMountainsBackground")
let tunnelForegroundTexture = SKTexture(imageNamed: "TunnelForeground")
let tunnelMidgroundTexture = SKTexture(imageNamed: "TunnelMidground")
let topMountainsBackgroundTextureIphone6 = SKTexture(imageNamed: "TopMountainsBackgroundIphone6")
let backgroundTexture = SKTexture(imageNamed: "Background")
let backgroundTextureIphone6 = SKTexture(imageNamed: "BackgroundIphone6")
let TopPlatformTexture = SKTexture(imageNamed: "TopPlatform")
let BottomPlatformTexture = SKTexture(imageNamed: "BottomPlatform")
let platformSmall1 = SKTexture(imageNamed: "platformSmall2")
let spikeObstacleTexture = SKTexture(imageNamed: "Spike")
let coinTexture = SKTexture(imageNamed: "Coin")
let PlayerTexture1 = SKTexture(imageNamed: "Player")
let tunnelTexture = SKTexture(imageNamed: "Tunnel")
let bottomGroundTexture = SKTexture(imageNamed: "BottomGround")

var stuffInTheScene = Bool()
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
let tutorials = SKNode()
let coins = SKNode()
let hitSound2 = SKAction.playSoundFileNamed("hit_sound_bestest.wav", waitForCompletion: false)
let coinPickUpSound = SKAction.playSoundFileNamed("point_low.wav", waitForCompletion: false)

let userSettingsDefaults: UserDefaults = UserDefaults.standard
var highscore = Int()
var notFirstTime = Bool()
var spawnLocation = 0

var platformSpawned = Bool()
var coinSpawnedFirst = Bool()
var newLocation = Int()
var coinFlip = Int()
var platformUpOrDown = Int()
var coinSpawned = Bool()
var muted = Bool()
var newHighscore = Bool()

// For ads
var didShowAds = 0

let fadeIn = SKAction.fadeIn(withDuration: 0.3)
let fadeOut = SKAction.fadeOut(withDuration: 0.1)
let fadeOutTutorial = SKAction.fadeOut(withDuration: 0.5)

var backgroundMusicPlayer = AVAudioPlayer()
let backgroundMusic = Bundle.main.path(forResource: "background_music", ofType: "wav")

var coinSoundPlayer = AVAudioPlayer()
let coinSound = Bundle.main.path(forResource: "point_low", ofType: "wav")

var hitSoundPlayer = AVAudioPlayer()
let hitSound = Bundle.main.path(forResource: "hit_sound_bestest", ofType: "wav")
