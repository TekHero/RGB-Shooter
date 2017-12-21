//
//  TitleScene.swift
//  Color Wars - Shooter
//
//  Created by Brian Lim on 3/20/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameKit

class TitleScene: SKScene, GKGameCenterControllerDelegate {
    
    var playBtn: UIButton!
    var tutorialBtn: UIButton!
    var leaderboardBtn: UIButton!
    var soundBtn: UIButton!
    var rateBtn: UIButton!
    var titleLbl: SKSpriteNode!
    
    var backgroundImg = SKSpriteNode(imageNamed: "SpaceBackground3")
    
    override func didMove(to view: SKView) {
        authenticateLocalPlayer()

        backgroundImg.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        backgroundImg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundImg.zPosition = -2
        self.addChild(backgroundImg)
        
        setUpText()
        
        let pulseUp = SKAction.scale(to: 1.2, duration: 1.0)
        let pulseDown = SKAction.scale(to: 0.8, duration: 1.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        self.titleLbl.run(repeatPulse)

    }
    
    
    func setUpText() {
        
        playBtn = UIButton(frame: CGRect(x: -500, y: 0, width: 120, height: 70))
        playBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        playBtn.setImage(UIImage(named: "PlayButtonV2"), for: UIControlState())
        playBtn.alpha = 0.0
        playBtn.center = CGPoint(x: (self.view!.frame.size.width / 2) - 70, y: self.frame.midY - 70)
        
        UIView.animate(withDuration: 1.2, animations: { () -> Void in
            self.playBtn.alpha = 1.0
        }) 
        
        playBtn.addTarget(self, action: #selector(TitleScene.playGame), for: UIControlEvents.touchUpInside)
        self.view?.addSubview(playBtn)
        
        leaderboardBtn = UIButton(frame: CGRect(x: 500, y: 0, width: 120, height: 70))
        leaderboardBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        leaderboardBtn.setImage(UIImage(named: "LeaderboardButton"), for: UIControlState())
        leaderboardBtn.alpha = 0.0
        leaderboardBtn.center = CGPoint(x: (self.view!.frame.size.width / 2) + 70, y: self.frame.midY - 70)

        UIView.animate(withDuration: 1.2, animations: { () -> Void in
            self.leaderboardBtn.alpha = 1.0
        }) 
        
        leaderboardBtn.addTarget(self, action: #selector(TitleScene.leaderboardBtnPressed), for: UIControlEvents.touchUpInside)
        self.view?.addSubview(leaderboardBtn)
        
        soundBtn = UIButton(frame: CGRect(x: -500, y: 0, width: 120, height: 70))
        soundBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        if soundOn == true {
            soundBtn.setImage(UIImage(named: "SoundOnButton"), for: UIControlState())
        } else {
            soundBtn.setImage(UIImage(named: "SoundOffButton"), for: UIControlState())
        }
        soundBtn.alpha = 0.0
        soundBtn.center = CGPoint(x: (self.view!.frame.size.width / 2) - 70, y: self.frame.midY + 45)

        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            self.soundBtn.alpha = 1.0
        }) 
        
        soundBtn.addTarget(self, action: #selector(TitleScene.soundBtnPressed), for: UIControlEvents.touchUpInside)
        self.view?.addSubview(soundBtn)
        
        // 180 // 140
        rateBtn = UIButton(frame: CGRect(x: 0, y: -1000, width: 120, height: 70))
        rateBtn.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        rateBtn.setImage(UIImage(named: "RateButtonV2"), for: UIControlState())
        rateBtn.alpha = 0.0
        rateBtn.center = CGPoint(x: (self.view!.frame.size.width / 2) + 70, y: self.frame.midY + 45)

        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            self.rateBtn.alpha = 1.0
        }) 
        
        rateBtn.addTarget(self, action: #selector(TitleScene.rateBtnPressed), for: UIControlEvents.touchUpInside)
        self.view?.addSubview(rateBtn)
        
        titleLbl = SKSpriteNode(imageNamed: "RGBShooter-Title-White")
        titleLbl.size = CGSize(width: 390, height: 340)
        titleLbl.position = CGPoint(x: self.frame.midX, y: 660)
        
        self.addChild(titleLbl)
    }
    
    func playGame() {
        
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        playBtn.removeFromSuperview()
        titleLbl.removeFromParent()
        leaderboardBtn.removeFromSuperview()
        soundBtn.removeFromSuperview()
        rateBtn.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    func rateBtnPressed() {
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1106210123")!)
    }
    
    
    func soundBtnPressed() {
        if soundOn == true {
            soundBtn.setImage(UIImage(named: "SoundOffButton"), for: UIControlState())
            soundOn = false
        } else {
            soundBtn.setImage(UIImage(named: "SoundOnButton"), for: UIControlState())
            soundOn = true
        }
    }
    
    // RGBShooter_26
    
    func leaderboardBtnPressed() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "put id here"
        self.view?.window?.rootViewController?.present(gcVC, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    //initiate gamecenter
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.view?.window?.rootViewController?.present(viewController!, animated: true, completion: nil)

            }
                
            else {
                print((GKLocalPlayer.localPlayer().isAuthenticated))
            }
        }
        
    }
    
}
