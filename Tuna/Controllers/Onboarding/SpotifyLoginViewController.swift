//
//  SpotifyLoginViewController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

class SpotifyLoginViewController: UIViewController {
    
    private let connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 30, green: 215, blue: 96, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Continue with Spotify", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(connectButton)
        
        
    }
    
    @objc private func didTapConnect(_ button: UIButton) {
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let buttonWidth = view.width * 0.8
        connectButton.frame = CGRect(x: (view.width - buttonWidth) / 2, y: (view.height - 50) / 2, width: buttonWidth, height: 50)
    }
    
    
}
