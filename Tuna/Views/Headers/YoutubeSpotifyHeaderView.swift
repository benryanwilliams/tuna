//
//  YoutubeSpotifyHeaderView.swift
//  Tuna
//
//  Created by Ben Williams on 07/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

protocol YoutubeSpotifyHeaderViewDelegate: AnyObject {
    func didTapYoutubeButton()
    func didTapSpotifyButton()
}

class YoutubeSpotifyHeaderView: UIView {
    
    weak var delegate: YoutubeSpotifyHeaderViewDelegate?
    
    private let youtubeButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .secondarySystemBackground
        button.setImage(UIImage(named: "youtubeNotPressed"), for: .normal)
        button.setImage(UIImage(named: "youtubePressed"), for: .selected)
        button.isSelected = true
        button.alpha = 1.0
        button.adjustsImageWhenHighlighted = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: -3, bottom: 10, right: 30)
        button.imageView?.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = false
        
        return button
    }()
    
    private let spotifyButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        button.setImage(UIImage(named: "spotifyNotPressed"), for: .normal)
        button.setImage(UIImage(named: "spotifyPressed"), for: .selected)
        button.alpha = 0.75
        button.adjustsImageWhenHighlighted = false
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 3, right: 30)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        youtubeButton.addTarget(self, action: #selector(didTapYoutubeButton), for: .touchUpInside)
        spotifyButton.addTarget(self, action: #selector(didTapSpotifyButton), for: .touchUpInside)
        
        addSubview(youtubeButton)
        addSubview(spotifyButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapYoutubeButton() {
        youtubeButton.isSelected = true
        youtubeButton.isHighlighted = false
        youtubeButton.backgroundColor = .secondarySystemBackground
        youtubeButton.alpha = 1
        youtubeButton.isUserInteractionEnabled = false
        
        spotifyButton.isSelected = false
        spotifyButton.backgroundColor = .systemBackground
        spotifyButton.alpha = 0.75
        spotifyButton.isUserInteractionEnabled = true
        
        delegate?.didTapYoutubeButton()
        
        
    }
    
    @objc private func didTapSpotifyButton() {
        spotifyButton.isSelected = true
        spotifyButton.isHighlighted = false
        spotifyButton.backgroundColor = .secondarySystemBackground
        spotifyButton.alpha = 1
        spotifyButton.isUserInteractionEnabled = false
        
        youtubeButton.isSelected = false
        youtubeButton.backgroundColor = .systemBackground
        youtubeButton.alpha = 0.75
        youtubeButton.isUserInteractionEnabled = true
        
        delegate?.didTapSpotifyButton()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        youtubeButton.frame = CGRect(
            x: 0,
            y: 3,
            width: (width / 2),
            height: 44
        )
        youtubeButton.layer.cornerRadius = 8.0
        youtubeButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        spotifyButton.frame = CGRect(
            x: youtubeButton.right,
            y: 3,
            width: (width / 2),
            height: 44
        )
        spotifyButton.layer.cornerRadius = 8.0
        spotifyButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    
    
    
}
