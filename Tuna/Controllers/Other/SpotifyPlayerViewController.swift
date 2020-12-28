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
    
    // MARK:- Create UI
    
    private let playerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textAlignment = .center
        return label
        
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
    }
    
    // MARK:- Config
    
    private func configurePlayerView() {
        view.addSubview(playerView)
        
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
    
    
    // MARK:- viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let videoHeight = view.width * 720 / 1280
        let bufferSize: CGFloat = 25
        let buttonSize: CGFloat = 36
        
        titleLabel.frame = CGRect(
            x: 0,
            y: ((view.height - addToLibraryButton.height - videoHeight - bufferSize) / 3) - 20 - bufferSize,
            width: view.width,
            height: 20
        )
        
        playerView.frame = CGRect(
            x: 0,
            y: (view.height - addToLibraryButton.height - videoHeight - bufferSize) / 3,
            width: view.width,
            height: videoHeight
        )
        
        addToLibraryButton.frame = CGRect(
            x: view.right - ((buttonSize + bufferSize) * 2),
            y: playerView.bottom + bufferSize,
            width: buttonSize,
            height: buttonSize
        )
        addToLibraryButton.layer.cornerRadius = 8.0
        
        copyLinkButton.frame = CGRect(
            x: view.right - buttonSize - bufferSize,
            y: playerView.bottom + bufferSize,
            width: buttonSize,
            height: buttonSize
        )
        copyLinkButton.layer.cornerRadius = 8.0
    }
    
}
