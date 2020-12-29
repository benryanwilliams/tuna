//
//  SpotifyTableViewCell.swift
//  Tuna
//
//  Created by Ben Williams on 29/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import SDWebImage
import UIKit

protocol SpotifyMoreButtonDelegate: AnyObject {
    func didTapSpotifyMoreButton(cell: SpotifyTableViewCell)
}

class SpotifyTableViewCell: UITableViewCell {
    static let identifier = "SpotifyTableViewCell"
    
    weak var delegate: SpotifyMoreButtonDelegate?
    
    private var model: SpotifyTrackModel?
    
    // MARK:- Create UI
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "spotifyTest")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Midnight on Rainbow Road"
        label.textColor = .label
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.text = "Leon Vynehall"
        label.textColor = .tunaGreen
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "3:20"
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let spotifyMoreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    // MARK:- Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .secondarySystemBackground
        clipsToBounds = true
        
        addSubviews()
        spotifyMoreButton.addTarget(self, action: #selector(didTapSpotifyMoreButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Actions
    
    public func configure(with model: SpotifyTrackModel) {
        // Configure cell, e.g. viewCountLabel.text = model.viewCount
        guard let thumbnailURL = URL(string: model.thumbnail) else {
            return
        }
        thumbnailImageView.sd_setImage(with: thumbnailURL, completed: nil)
        titleLabel.text = model.title
        artistLabel.text = model.artist
        durationLabel.text = String(model.trackLength)
    }
    
    @objc private func didTapSpotifyMoreButton() {
        delegate?.didTapSpotifyMoreButton(cell: self)
    }
    
    private func addSubviews() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(spotifyMoreButton)
        
    }
    
    // MARK:- layoutSubviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bufferSize: CGFloat = 18
        let thumbnailSize: CGFloat = contentView.height - bufferSize
        
        thumbnailImageView.frame = CGRect(
            x: bufferSize,
            y: bufferSize / 2,
            width: thumbnailSize,
            height: thumbnailSize
        )
        
        spotifyMoreButton.frame = CGRect(
            x: contentView.right - 30 - bufferSize,
            y: 0,
            width: 40,
            height: 40
        )
        
        titleLabel.frame = CGRect(
            x: thumbnailImageView.right + bufferSize,
            y: bufferSize / 2,
            width: contentView.width - (bufferSize * 3) - thumbnailImageView.width - spotifyMoreButton.width,
            height: (contentView.height - (bufferSize * 2)) / 2
        )
        titleLabel.sizeToFit()
        
        artistLabel.frame = CGRect(
            x: thumbnailImageView.right + bufferSize,
            y: titleLabel.bottom,
            width: contentView.width - (bufferSize * 3) - thumbnailImageView.width - spotifyMoreButton.width,
            height: (contentView.height - (bufferSize * 2)) / 4
        )
        
        durationLabel.frame = CGRect(
            x: thumbnailImageView.right + bufferSize,
            y: artistLabel.bottom,
            width: contentView.width - (bufferSize * 3) - thumbnailImageView.width - spotifyMoreButton.width,
            height: (contentView.height - (bufferSize * 2)) / 4
        )
    }
    
}
