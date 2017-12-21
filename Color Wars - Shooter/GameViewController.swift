//
//  GameViewController.swift
//  Color Wars - Shooter
//
//  Created by Brian Lim on 3/20/16.
//  Copyright (c) 2016 codebluapps. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.checkAd), name: NSNotification.Name(rawValue: "showInterstitialKey"), object: nil)
    
        self.interstitial = createAndLoadInterstitial()
        
        let request = GADRequest()
        request.testDevices = ["kGADSimulatorID"]
        self.interstitial.load(request)

        if let scene = TitleScene(fileNamed:"TitleScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }
    
    func checkAd() {
        if interstitial.isReady {
            
            if self.interstitial.isReady {
                let rNumber1 = arc4random() % 46 + 1
                let rNumber2 = arc4random() % 46 + 1
                if rNumber1 % 2 == 1 && rNumber2 % 1 == 0 {
                    
                    self.interstitial.present(fromRootViewController: self)
                }
            }

        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6536902852765774/5449342249")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        
        self.interstitial = createAndLoadInterstitial()
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
