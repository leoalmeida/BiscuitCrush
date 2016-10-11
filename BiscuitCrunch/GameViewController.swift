//
//  GameViewController.swift
//  BiscuitCrunch
//
//  Created by Leonardo Almeida silva ferreira on 24/09/16.
//  Copyright (c) 2016 kkwFwk. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

    var scene: GameScene!
    var level: Level!
    var tapGestureRecognizer: UITapGestureRecognizer!

    
    lazy var gameBackgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var levelStackView: UIStackView!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBAction func shuffleButtonPressed(_: AnyObject) {
        scene.shuffle()
        scene.decrementMoves()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let gamescene = GameScene(fileNamed: "GameScene") {
            // Create and configure the scene.
            //scene = GameScene(size: skView.bounds.size)
            scene = gamescene
            scene.gameSceneDelegate = self
            
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.isMultipleTouchEnabled = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            // skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .aspectFill
            scene.level = level
            
            // Present the scene.
            skView.presentScene(scene)
        
        
            // Start menu background music.
            SKTAudio.sharedInstance().playBackgroundMusic(filename: "Mining by Moonlight.mp3")
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

extension GameViewController: GameSceneProtocol {
    func didSelectCancelButton(gameScene: GameScene) {
        navigationController?.popToRootViewController(animated: false)
    }
    
    func didShowOverlay(gameScene: GameScene) {
        self.shuffleButton.isHidden = true
        self.stackView.isHidden = true
        self.levelStackView.isHidden = true
    }
    
    func didDismissOverlay(gameScene: GameScene) {
        self.shuffleButton.isHidden = false
        self.stackView.isHidden = false
        self.levelStackView.isHidden = false
    }
    
    func updateLabels(targetScore: Int, movesLeft: Int, score: Int) {
        targetLabel.text = String(format: "%ld", targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
        currentLevelLabel.text = String(format: "%ld", scene.level.currentLevel())
    }
    
    #if os (tvOS)
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        scene.pressesBegan(presses, withEvent: event)
    }
    #endif
}
