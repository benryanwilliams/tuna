//
//  SearchViewController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK:- Create UI
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    private let headerView = YoutubeSpotifyHeaderView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchBar()
        configureNavBarMoreButton()
        
        headerView.delegate = self
        tableView.delegate = self
        
        
        view.addSubview(headerView)
        view.addSubview(tableView)
    }
    
    // MARK:- Config
    
    private func configureSearchBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
    }
    
    private func configureNavBarMoreButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTapNavBarMoreButton)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    // MARK:- Actions
    
    @objc private func didTapNavBarMoreButton() {
        // Show action sheet with Search History and Cancel
    }
    
    // MARK:- viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.bottom)!, width: view.width, height: 50)
        tableView.frame = CGRect(x: 0, y: headerView.bottom, width: view.width, height: view.height)
    }
}

// MARK:- Table View Delegate and Data Source Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell pressed")
    }
    
}

// MARK:- YoutubeSpotifyHeaderViewDelegate Methods

extension SearchViewController: YoutubeSpotifyHeaderViewDelegate {
    func didTapYoutubeButton() {
        // Open Youtube search results
    }
    
    func didTapSpotifyButton() {
        // Open Spotify search results
    }
    
    
}

