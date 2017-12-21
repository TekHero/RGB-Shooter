//
//  GameoverScene.swift
//  Color Wars - Shooter
//
//  Created by Brian Lim on 3/20/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import Foundation
import SpriteKit
import GoogleMobileAds
import GameKit

class GameoverScene: SKScene, SKPhysicsContactDelegate, GADInterstitialDelegate {
    
    var userScoreTitle: UILabel!
    var userScoreLbl: UILabel!
    
    var userHighScoreTitle: UILabel!
    var userHighScoreLbl: UILabel!
    
    var playAgainBtn: UIButton!
    var homeButton: UIButton!
    
    var totalAmountOfMeteorsDestroyedTitle: UILabel!
    var numberOfMeteorsDestroyedLbl: UILabel!
    
    var userScore = 0
    var userHighscore = 0
    var meteorsDestroyed = 0
    
    var viewAppearedCounter = 0
    var viewAppeared = 0
    
    var shouldAnimate = false
    
    var interstitial: GADInterstitial!
    
    var backgroundImg = SKSpriteNode(imageNamed: "SpaceBackground3")
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        backgroundImg.size = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        backgroundImg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundImg.zPosition = -2
        self.addChild(backgroundImg)
        
        checkScore()
        setUpText()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showInterstitialKey"), object: nil)
        
    }

    
    func checkScore() {
        
        // Checking to see if there is a integer for the key "SCORE"
        if let score: Int = UserDefaults.standard.integer(forKey: "SCORE") {
            userScore = score
            
            // Checking to see if there if a integer for the key "HIGHSCORE"
            if let highscore: Int = UserDefaults.standard.integer(forKey: "HIGHSCORE") {
                
                // If there is, check if the current score is greater then the value of the current highscore
                if score > highscore {
                    // If it is, set the current score as the new high score
                    UserDefaults.standard.set(score, forKey: "HIGHSCORE")
                    userHighscore = score
                    saveHighscore(score)
                    shouldAnimate = true
                } else {
                    // Score is not greater then highscore
                }
            } else {
                // There is no integer for the key "HIGHSCORE"
                // Set the current score as the highscore since there is no value for highscore yet
                UserDefaults.standard.set(score, forKey: "HIGHSCORE")
                userHighscore = score
                saveHighscore(score)
                shouldAnimate = true
            }
        }
        
        // Checking to see if there a integer for the key "HIGHSCORE"
        if let highscore: Int = UserDefaults.standard.integer(forKey: "HIGHSCORE") {
            // If so, then set the value of this key to the userHighscore variable
            userHighscore = highscore
        }
        
        if let meteorCount: Int = UserDefaults.standard.integer(forKey: "MeteorCounter") {
            meteorsDestroyed = meteorCount
        }
    }
    
    func setUpText() {

        userScoreTitle = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 100))
        userScoreTitle.center = CGPoint(x: (view!.frame.size.width / 2), y: 50)
        userScoreTitle.textColor = UIColor(red: 99.0 / 255.0, green: 240.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        userScoreTitle.textAlignment = NSTextAlignment.center
        userScoreTitle.font = UIFont(name: "Prototype", size: 25)
        userScoreTitle.text = "Score"
        
        self.view?.addSubview(userScoreTitle)
        
        userScoreLbl = UILabel(frame: CGRect(x: 100, y: 200, width: self.view!.frame.size.width, height: 60)) // 145
        userScoreLbl.center = CGPoint(x: (view!.frame.size.width / 2), y: 100)
        userScoreLbl.textColor = UIColor.white
        userScoreLbl.textAlignment = NSTextAlignment.center
        userScoreLbl.font = UIFont(name: "Prototype", size: 22)
        userScoreLbl.text = "\(formatScore(score: userScore))"
        
        self.view?.addSubview(userScoreLbl)
        
        userHighScoreTitle = UILabel(frame: CGRect(x: 100, y: 100, width: 200, height: 100))
        userHighScoreTitle.center = CGPoint(x: (view!.frame.size.width / 2), y: 150)
        userHighScoreTitle.textColor = UIColor(red: 131.0 / 255.0, green: 255.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
        userHighScoreTitle.textAlignment = NSTextAlignment.center
        userHighScoreTitle.font = UIFont(name: "Prototype", size: 25)
        userHighScoreTitle.text = "Record"
        
        self.view?.addSubview(userHighScoreTitle)
        
        userHighScoreLbl = UILabel(frame: CGRect(x: 100, y: 100, width: self.view!.frame.size.width, height: 60))
        userHighScoreLbl.center = CGPoint(x: (view!.frame.size.width / 2), y: 200)
        userHighScoreLbl.textColor = UIColor.white
        userHighScoreLbl.textAlignment = NSTextAlignment.center
        userHighScoreLbl.font = UIFont(name: "Prototype", size: 22)
        userHighScoreLbl.text = "\(formatScore(score: userHighscore))"
        if shouldAnimate == true {
            animateText()
        }
        
        self.view?.addSubview(userHighScoreLbl)
        
        totalAmountOfMeteorsDestroyedTitle = UILabel(frame: CGRect(x: 100, y: 100, width: self.view!.frame.size.width, height: 45))
        totalAmountOfMeteorsDestroyedTitle.center = CGPoint(x: self.view!.frame.size.width / 2, y: 275)
        totalAmountOfMeteorsDestroyedTitle.textColor = UIColor(red: 255.0 / 255.0, green: 174.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
        totalAmountOfMeteorsDestroyedTitle.textAlignment = NSTextAlignment.center
        totalAmountOfMeteorsDestroyedTitle.font = UIFont(name: "Prototype", size: 17)
        totalAmountOfMeteorsDestroyedTitle.text = "Total Number of Meteors Destroyed"
        
        self.view?.addSubview(totalAmountOfMeteorsDestroyedTitle)
        
        numberOfMeteorsDestroyedLbl = UILabel(frame: CGRect(x: 100, y: 100, width: self.view!.frame.size.width, height: 45))
        numberOfMeteorsDestroyedLbl.center = CGPoint(x: self.view!.frame.size.width / 2, y: 320)
        numberOfMeteorsDestroyedLbl.textColor = UIColor.white
        numberOfMeteorsDestroyedLbl.textAlignment = NSTextAlignment.center
        numberOfMeteorsDestroyedLbl.font = UIFont(name: "Prototype", size: 22)
        numberOfMeteorsDestroyedLbl.text = "\(formatScore(score: meteorsDestroyed))"
        
        self.view?.addSubview(numberOfMeteorsDestroyedLbl)
        
        playAgainBtn = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 180))
        playAgainBtn.center = CGPoint(x: (view!.frame.size.width / 2) - 80, y: 435) // 400
        playAgainBtn.setBackgroundImage(UIImage(named: "PlayAgainButton"), for: UIControlState())
        playAgainBtn.addTarget(self, action: #selector(GameoverScene.playAgainBtnPressed), for: UIControlEvents.touchUpInside)
        
        self.view?.addSubview(playAgainBtn)
        
        homeButton = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 180))
        homeButton.center = CGPoint(x: (view!.frame.size.width / 2) + 80, y: 435) // 400
        homeButton.setBackgroundImage(UIImage(named: "HomeButtonV2"), for: UIControlState())
        homeButton.addTarget(self, action: #selector(GameoverScene.homeButtonPressed), for: UIControlEvents.touchUpInside)
        
        self.view?.addSubview(homeButton)

    }
    
    func formatScore(score: Int) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        let value = fmt.string(from: NSNumber(score))
        
        return value!
    }
    
    func playAgainBtnPressed() {
        
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        userScoreTitle.removeFromSuperview()
        userScoreLbl.removeFromSuperview()
        userHighScoreTitle.removeFromSuperview()
        userHighScoreLbl.removeFromSuperview()
        playAgainBtn.removeFromSuperview()
        homeButton.removeFromSuperview()
        totalAmountOfMeteorsDestroyedTitle.removeFromSuperview()
        numberOfMeteorsDestroyedLbl.removeFromSuperview()
        
        _ = UserDefaults.standard.setValue(0, forKey: "MeteorCounter")
        
        if let scene = GameScene(fileNamed: "GameScene") {
            
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
        
    }
    
    func homeButtonPressed() {
        
        userScoreTitle.removeFromSuperview()
        userScoreLbl.removeFromSuperview()
        userHighScoreTitle.removeFromSuperview()
        userHighScoreLbl.removeFromSuperview()
        playAgainBtn.removeFromSuperview()
        homeButton.removeFromSuperview()
        totalAmountOfMeteorsDestroyedTitle.removeFromSuperview()
        numberOfMeteorsDestroyedLbl.removeFromSuperview()
        
        _ = UserDefaults.standard.setValue(0, forKey: "MeteorCounter")
        
        
        if let scene = TitleScene(fileNamed: "TitleScene") {
            
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    // RGBShooter_26
    
    //send high score to leaderboard
    func saveHighscore(_ score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            let scoreReporter = GKScore(leaderboardIdentifier: "") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error")
                }
                } as! (Error?) -> Void)
            
        }
        
        
    }
    
    func animateText() {
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            
            // Insert a label, set its alpha to 1
            self.userHighScoreLbl.alpha = 1
            
            }, completion: {
                
                (Completed: Bool) -> Void in
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
                    
                    // Insert a label, set its alpha to 0
                    self.userHighScoreLbl.alpha = 0
                    
                    }, completion: {
                        
                        (Completed: Bool) -> Void in
                        
                        self.animateText()
                        
                        
                })
        })
        
    }
    
}
