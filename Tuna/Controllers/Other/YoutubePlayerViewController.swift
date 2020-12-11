//
//  YoutubePlayerViewController.swift
//  Tuna
//
//  Created by Ben Williams on 12/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import youtube_ios_player_helper
import UIKit

protocol YoutubePlayerViewControllerDelegate: AnyObject {
    func didTapAddToLibraryButton()
    func didTapCopyLinkButton()
}

class YoutubePlayerViewController: UIViewController, YTPlayerViewDelegate {
    
    weak var delegate: YoutubePlayerViewControllerDelegate?
    
    public var model: YoutubeVideoModel?
    
    // MARK:- Create UI
    
    private let playerView: YTPlayerView = {
        let view = YTPlayerView()
        return view
    }()
    
    private let addToLibraryButton: UIButton = {
       let button = UIButton()
        button.setTitle("Add to library", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.clipsToBounds = true
        button.backgroundColor = .secondarySystemBackground
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        return button
    }()
    
    private let copyLinkButton: UIButton = {
       let button = UIButton()
        button.setTitle("Copy link", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.clipsToBounds = true
        button.backgroundColor = .secondarySystemBackground
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        return button
    }()
    
    // MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .label
        
        configurePlayerView()
        configureAddToLibraryButton()
        configureCopyLinkButton()
    }
    
    // MARK:- Config
    
    private func configurePlayerView() {
        view.addSubview(playerView)
        playerView.delegate = self
        guard let id = model?.id else {
            return
        }
        playerView.load(withVideoId: id, playerVars: ["playsinline" : 1])
    }
    
    private func configureAddToLibraryButton() {
        view.addSubview(addToLibraryButton)
        
        addToLibraryButton.addTarget(self, action: #selector(didTapAddToLibraryButton), for: .touchUpInside)
        
        // If track is in library then display 'remove', otherwise display 'add'
        if model?.isInLibrary == true {
            addToLibraryButton.setTitle("Remove from library", for: .normal)
        }
        else {
            addToLibraryButton.setTitle("Add to library", for: .normal)
        }
    }
    
    private func configureCopyLinkButton() {
        view.addSubview(copyLinkButton)
        addToLibraryButton.addTarget(self, action: #selector(didTapCopyLinkButton), for: .touchUpInside)
    }
    
    // MARK:- Actions
    
    @objc private func didTapAddToLibraryButton() {
        delegate?.didTapAddToLibraryButton()
    }
    
    @objc private func didTapCopyLinkButton() {
        delegate?.didTapCopyLinkButton()
    }
    
    
    // MARK:- viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.width * 720 / 1280
        )
        
        addToLibraryButton.frame = CGRect(
            x: 0,
            y: playerView.bottom + 4,
            width: view.width,
            height: 70
        )
        addToLibraryButton.layer.cornerRadius = 8.0
        
        copyLinkButton.frame = CGRect(
            x: 0,
            y: addToLibraryButton.bottom + 4,
            width: view.width,
            height: 70
        )
        copyLinkButton.layer.cornerRadius = 8.0
    }
    
}
