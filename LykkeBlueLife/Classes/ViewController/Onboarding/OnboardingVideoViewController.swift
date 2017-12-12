//
//  OnboardingVideoViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/7/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class LandscapeAVIPlayerController: AVPlayerViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
}

class OnboardingVideoViewController: UIViewController {
    @IBOutlet weak var videoContainer: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func play(_ sender: Any) {
        guard let url = URL(string: "https://lkefiles.blob.core.windows.net/movies/LykkeBlue/Intro.mp4") else { return }
        
        let player = AVPlayer(url: url)
        let playerViewController = LandscapeAVIPlayerController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}
