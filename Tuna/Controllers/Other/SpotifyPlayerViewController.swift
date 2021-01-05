//
//  SpotifyPlayerViewController.swift
//  Tuna
//
//  Created by Ben Williams on 29/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

protocol SpotifyPlayerViewControllerDelegate: AnyObject {
    func didTapSPAddToLibraryButton(isInLibrary: Bool, model: SpotifyTrackModel?)
}

class SpotifyPlayerViewController: UIViewController {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var delegate: SpotifyPlayerViewControllerDelegate?
    
    public var model: SpotifyTrackModel?
    
    public var isInLibrary = false
    public var isPlaying = false
    
    // MARK:- Player
    var player: MusicPlayer?
    var appRemote: SPTAppRemote? {
        get { return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote }
    }
    
    // MARK:- Create UI
    
    private let albumImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
        
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tunaGreen
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let timerSlider: UISlider = {
        let slider = UISlider()
        return slider
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.imageView?.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private let rewindButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gobackward.15"), for: .normal)
        button.imageView?.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "goforward.15"), for: .normal)
        button.imageView?.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private let addToLibraryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "folder.badge.plus"), for: .normal)
        button.imageView?.tintColor = .secondaryLabel
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        return button
    }()
    
    private let copyLinkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.imageView?.tintColor = .secondaryLabel
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.clipsToBounds = true
        button.backgroundColor = .systemBackground
        return button
    }()
    
    // MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.tintColor = .label
        
        configurePlayerView()
        configureAddToLibraryButton()
        configureCopyLinkButton()
        configureTitle()
        configureArtist()
        configurePlayButton()
        configureSlider()
        
        
        view.addSubview(rewindButton)
        view.addSubview(forwardButton)
    }
    
    // MARK:- Config
    
    private func configurePlayerView() {
        view.addSubview(albumImageView)
        guard let imageUrlString = model?.thumbnail else {
            return
        }
        guard let imageUrl = URL(string: imageUrlString) else {
            return
        }
        albumImageView.sd_setImage(with: imageUrl, completed: nil)
        
    }
    
    private func configureAddToLibraryButton() {
        view.addSubview(addToLibraryButton)
        
        addToLibraryButton.addTarget(self, action: #selector(didTapSPAddToLibraryButton), for: .touchUpInside)
        
        // If track is in library then display 'remove', otherwise display 'add'
        if isInLibrary == true {
            addToLibraryButton.setImage(UIImage(systemName: "folder.fill.badge.minus"), for: .normal)
        }
        else {
            addToLibraryButton.setImage(UIImage(systemName: "folder.badge.plus"), for: .normal)
        }
    }
    
    private func configureCopyLinkButton() {
        view.addSubview(copyLinkButton)
        copyLinkButton.addTarget(self, action: #selector(didTapCopyLinkButton), for: .touchUpInside)
    }
    
    private func configureTitle() {
        view.addSubview(titleLabel)
        titleLabel.text = model?.title
    }
    
    private func configureArtist() {
        view.addSubview(artistLabel)
        artistLabel.text = model?.artist
    }
    
    private func configureSlider() {
        view.addSubview(timerSlider)
    }
    
    private func configurePlayButton() {
        view.addSubview(playButton)
        if isPlaying == false {
            playButton.setImage(UIImage(systemName: "play"), for: .normal)
            guard let urlString = model?.url else {
                return
            }
            playTrackFrom(urlString: urlString)
        }
        else {
            playButton.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    // MARK:- Actions
    
    @objc private func didTapSPAddToLibraryButton() {
        delegate?.didTapSPAddToLibraryButton(isInLibrary: isInLibrary, model: model)
        isInLibrary = !isInLibrary
        configureAddToLibraryButton()
    }
    
    @objc private func didTapCopyLinkButton() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = model?.url
    }
    
    func playTrackFrom(urlString: String) {
        let musicPlayer = MusicPlayer()
        player = musicPlayer
        player?.initPlayer(url: urlString)
        player?.play()
    }
    
    
    
    // MARK:- viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bufferSize: CGFloat = 15
        let transportBufferSize: CGFloat = 25
        let playButtonSize: CGFloat = 50
        let backButtonSize: CGFloat = 40
        let linkButtonSize: CGFloat = 30
        let imageSize = view.width - (bufferSize * 4)
        
        albumImageView.frame = CGRect(
            x: bufferSize * 2,
            y: bufferSize,
            width: imageSize,
            height: imageSize
        )
        
        titleLabel.frame = CGRect(
            x: bufferSize * 2,
            y: albumImageView.bottom + bufferSize,
            width: imageSize,
            height: 30
        )
        
        artistLabel.frame = CGRect(
            x: bufferSize * 2,
            y: titleLabel.bottom,
            width: imageSize,
            height: 30
        )
        
        timerSlider.frame = CGRect(
            x: bufferSize * 2,
            y: artistLabel.bottom + bufferSize,
            width: imageSize,
            height: 30
        )
        
        playButton.frame = CGRect(
            x: (view.width / 2) - (playButtonSize / 2),
            y: timerSlider.bottom + bufferSize,
            width: playButtonSize,
            height: playButtonSize
        )
        
        rewindButton.frame = CGRect(
            x: playButton.left - transportBufferSize - playButtonSize,
            y: timerSlider.bottom + bufferSize,
            width: backButtonSize,
            height: backButtonSize
        )
        
        copyLinkButton.frame = CGRect(
            x: rewindButton.left - transportBufferSize - linkButtonSize,
            y: timerSlider.bottom + bufferSize,
            width: linkButtonSize,
            height: linkButtonSize
        )
        copyLinkButton.layer.cornerRadius = 8.0
        
        forwardButton.frame = CGRect(
            x: playButton.right + transportBufferSize,
            y: timerSlider.bottom + bufferSize,
            width: backButtonSize,
            height: backButtonSize
        )
        
        addToLibraryButton.frame = CGRect(
            x: forwardButton.right + transportBufferSize,
            y: timerSlider.bottom + bufferSize,
            width: linkButtonSize,
            height: linkButtonSize
        )
        addToLibraryButton.layer.cornerRadius = 8.0
        
    }
    
}
