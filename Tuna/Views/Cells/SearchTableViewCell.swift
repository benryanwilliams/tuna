//
//  SearchTableViewCell.swift
//  Tuna
//
//  Created by Ben Williams on 07/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import SDWebImage
import UIKit

protocol MoreButtonDelegate: AnyObject {
    func didTapMoreButton(cell: SearchTableViewCell)
}

class SearchTableViewCell: UITableViewCell {
    static let identifier = "SearchTableViewCell"
    
    weak var delegate: MoreButtonDelegate?
    
    private var model: YoutubeVideoModel?
    
    // MARK:- Create UI
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "test")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Galt McDermott - Coffee Cold"
        label.textColor = .label
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let userLabel: UILabel = {
        let label = UILabel()
        label.text = "sinextransum"
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let viewCountLabel: UILabel = {
        let label = UILabel()
        label.text = "568,765 views"
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let moreButton: UIButton = {
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
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Actions
    
    public func configure(with model: YoutubeVideoModel) {
        // Configure cell, e.g. viewCountLabel.text = model.viewCount
        guard let thumbnailURL = URL(string: model.thumbnail) else {
            return
        }
        thumbnailImageView.sd_setImage(with: thumbnailURL, completed: nil)
        titleLabel.text = model.title
        userLabel.text = model.user
        viewCountLabel.text = String(model.viewCount)
    }
    
    @objc private func didTapMoreButton() {
        delegate?.didTapMoreButton(cell: self)
    }
    
    private func addSubviews() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(userLabel)
        contentView.addSubview(viewCountLabel)
        contentView.addSubview(moreButton)
        
    }
    
    // MARK:- layoutSubviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bufferSize: CGFloat = 18
        
        thumbnailImageView.frame = CGRect(
            x: bufferSize * 2,
            y: bufferSize / 2,
            width: (contentView.width - (bufferSize * 2)) / 3,
            height: contentView.height - (bufferSize)
        )
        
        moreButton.frame = CGRect(
            x: contentView.right - 20 - bufferSize,
            y: 0,
            width: 40,
            height: 40
        )
        
        titleLabel.frame = CGRect(
            x: thumbnailImageView.right + (bufferSize * 1.75),
            y: bufferSize / 2,
            width: contentView.width - (bufferSize * 5.5) - thumbnailImageView.width - moreButton.width,
            height: (contentView.height - (bufferSize * 2)) / 2
        )
        titleLabel.sizeToFit()
        
        userLabel.frame = CGRect(
            x: thumbnailImageView.right + (bufferSize * 1.75),
            y: titleLabel.bottom,
            width: contentView.width - (bufferSize * 5.5) - thumbnailImageView.width - moreButton.width,
            height: (contentView.height - (bufferSize * 2)) / 4
        )
        
        viewCountLabel.frame = CGRect(
            x: thumbnailImageView.right + (bufferSize * 1.75),
            y: userLabel.bottom,
            width: contentView.width - (bufferSize * 5.5) - thumbnailImageView.width - moreButton.width,
            height: (contentView.height - (bufferSize * 2)) / 4
        )
    }
    
}
