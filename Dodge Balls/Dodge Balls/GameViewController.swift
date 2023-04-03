//
//  GameViewController.swift
//  Dodge Balls
//
//  Created by Valentina Carfagno on 5/3/19.
//  Copyright © 2019 RSC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import os.log


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        gameAchievements()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = TitleScene(fileNamed: "TitleScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    //Mark Private Functions
    private func gameAchievements() {
        // load any saved score, otherwise load sample score
        if let savedScores = loadScores() {
            scores += savedScores
        }
        else {
            // load the sample data
            loadSampleScores()
        }
    }
    private func loadSampleScores() {
        guard let saved1 = SavedGame(name: "Dodge Balls", score: 0) else {
            fatalError("unable to instantiate saved1")
        }
        scores += [saved1]
    }
    private func loadScores() -> [SavedGame]?
    {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SavedGame.ArchiveURL.path)
        as? [SavedGame]
    }
}
