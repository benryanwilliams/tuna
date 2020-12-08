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
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    private let headerView = YoutubeSpotifyHeaderView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        return tableView
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    
    // MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchBar()
        configureNavBarMoreButton()
        
        headerView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        configureDimmedView()
    }
    
    // MARK:- Config
    
    private func configureSearchBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        searchBar.delegate = self
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
    
    private func configureDimmedView() {
        view.addSubview(dimmedView)
        
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didFinishSearch)
        )
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        
        dimmedView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapNavBarMoreButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(
            title: "Search history",
            style: .default,
            handler: { action in
            // Present search history view controller
                
        }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        
        actionSheet.view.tintColor = .label
        
        present(actionSheet, animated: true)
    }
    
    // MARK:- viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(
            x: 0,
            y: (self.navigationController?.navigationBar.bottom ?? 10),
            width: view.width,
            height: 50
        )
        
        tableView.frame = CGRect(
            x: 0,
            y: headerView.bottom,
            width: view.width,
            height: view.height - headerView.height - (tabBarController?.tabBar.height ?? 10) - (navigationController?.navigationBar.height ?? 10)
        )
        
        dimmedView.frame = view.bounds
    }
}

// MARK:- Search bar delegate methods

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        didCancelSearch()
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        query(with: text)
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didCancelSearch)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        dimmedView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmedView.alpha = 0.4
        }) { (done) in
            if done {
               self.tableView.isHidden = false
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        didFinishSearch()
    }
    
    @objc private func didFinishSearch() {
        searchBar.resignFirstResponder()
        configureNavBarMoreButton()
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmedView.alpha = 0
        }) { (done) in
            if done {
                self.dimmedView.isHidden = true
            }
        }
        
    }
    
    @objc private func didCancelSearch() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        configureNavBarMoreButton()
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmedView.alpha = 0
        }) { (done) in
            if done {
                self.dimmedView.isHidden = true
            }
        }
        
    }
    
    private func query(with text: String) {
        // Perform YouTube search with text
        print("Search button pressed")
    }
    
}

// MARK:- Table View Delegate and Data Source Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
        cell.delegate = self
        cell.configure(with: "Model goes here")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell pressed")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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

// MARK:- moreButtonDelegate Methods

extension SearchViewController: MoreButtonDelegate {
    func didTapMoreButton(with model: String) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // TODO:- Add 'if' statement here so that if the video is already in the library then it says 'Remove from library' (also make this style .destructive so that it is red), otherwise it should say 'Add to library'
        
        actionSheet.addAction(UIAlertAction(
            title: "Add to library",
            style: .default,
            handler: { action in
                // Add to array of models within library and display a message that automatically disappears saying that it has successfully been added (otherwise, show an error message)
            }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Copy link",
            style: .default,
            handler: { action in
                // Fetch link to video and add to clipboard and display a message that automatically disappears saying 'Link copied' if it has successfully been added to the clipboard
        }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
     
        actionSheet.view.tintColor = .label
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    
}

