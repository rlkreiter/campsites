//
//  GameViewController.swift
//  Campsites
//
//  Created by Ryan Kreiter on 4/20/16.
//  Copyright (c) 2016 Ryan Kreiter. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // The scene draws the tiles and cookie sprites, and handles swipes.
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(title: "Restart", style: .Plain, target: self, action: #selector(GameViewController.restart))
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.title = "Campsites"
        
        // Configure the view.
        let skView = self.view as! SKView
        scene = GameScene(size: skView.bounds.size)
        scene.viewController = self
        scene.drawBoard(11)
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }

    func restart() {
        print("Restarting")
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
