//
//  LibraryViewController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var models = [YoutubeLibraryModel]()
    
    // MARK:- Create UI
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Filter"
        return searchBar
    }()
    
    private let headerView = YoutubeSpotifyHeaderView()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .secondarySystemBackground
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
        
        // Remove line above tab bar
        self.tabBarController!.tabBar.layer.borderWidth = 0.50
        self.tabBarController!.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBarController?.tabBar.clipsToBounds = true
        
        self.tabBarController?.tabBar.barTintColor = .systemBackground
        
        // Remove space below navbar following 'Translucent' being unchecked
        extendedLayoutIncludesOpaqueBars = true
        
        // Remove line below navigation bar
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        configureSearchBar()
        configureNavBarMoreButton()
        
        headerView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        
        configureDimmedView()
        
    }
    
    // MARK:- viewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchLibraryData(containing: nil)

    }
    
    // MARK:- Config
    
    private func configureSearchBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        searchBar.delegate = self
    }
    
    private func configureNavBarMoreButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3.decrease"),
            style: .plain,
            target: self,
            action: #selector(didTapNavBarMoreButton)
        )
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
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
    
    // MARK:- Actions
    
    @objc private func didTapNavBarMoreButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(
            title: "Downloaded",
            style: .default,
            handler: { action in
                // Filter to only show songs that have been downloaded
                
        }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Not downloaded",
            style: .default,
            handler: { action in
                // Filter to only show songs that haven't been downloaded
                
        }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Show all",
            style: .default,
            handler: { action in
                // Filter to show all songs
                 
        }))
        
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        
        actionSheet.view.tintColor = .label
        
        present(actionSheet, animated: true)
    }
    
    private func fetchLibraryData(containing text: String?) {
        let request = YoutubeLibraryModel.createFetchRequest()
        
        var titlePredicate: NSPredicate?
        
        if text != nil {
            titlePredicate = NSPredicate(format: "%K CONTAINS[c] %@", argumentArray: [#keyPath(YoutubeLibraryModel.title), text!])
        }
        else {
            titlePredicate = nil
        }
        
        request.predicate = titlePredicate
        
        let sortByDate = NSSortDescriptor(key: "dateAdded", ascending: true)
        request.sortDescriptors = [sortByDate]
        
        do {
            LibraryViewController.models = try context.fetch(request)
        }
        catch {
            print("Error fetching: \(error)")
        }
        tableView.reloadData()
    }
    
    private func deleteLibraryData(model: YoutubeLibraryModel, at indexPath: IndexPath) {
        context.delete(model)
        appDelegate.saveContext()
        LibraryViewController.models.remove(at: indexPath.row)
        tableView.reloadData()
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
            y: headerView.bottom - 3,
            width: view.width,
            height: view.height - headerView.height - (tabBarController?.tabBar.height ?? 10) - (navigationController?.navigationBar.height ?? 10)
        )
        
        dimmedView.frame = view.bounds
    }
    
}


// MARK:- Search bar delegate methods

extension LibraryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        didFinishSearch()
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        fetchLibraryData(containing: text)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            fetchLibraryData(containing: nil)
        }
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
        fetchLibraryData(containing: nil)
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
    
}

// MARK:- Table View Delegate and Data Source Methods

extension LibraryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LibraryViewController.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
        cell.delegate = self
        guard !LibraryViewController.models.isEmpty else {
            return UITableViewCell()
        }
        let libraryModel = LibraryViewController.models[indexPath.row]
        
        let cellModel = YoutubeVideoModel(
            thumbnail: libraryModel.thumbnail,
            title: libraryModel.title,
            user: libraryModel.user,
            viewCount: libraryModel.viewCount,
            id: libraryModel.id,
            url: libraryModel.url,
            isInLibrary: libraryModel.isInLibrary
        )
        
        cell.configure(with: cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = nil
        let vc = YoutubePlayerViewController()
        vc.isInLibrary = true
        vc.delegate = self
        
        let libraryModel = LibraryViewController.models[indexPath.row]
        
        let cellModel = YoutubeVideoModel(
            thumbnail: libraryModel.thumbnail,
            title: libraryModel.title,
            user: libraryModel.user,
            viewCount: libraryModel.viewCount,
            id: libraryModel.id,
            url: libraryModel.url,
            isInLibrary: libraryModel.isInLibrary
        )
        vc.model = cellModel
        navigationController?.pushViewController(vc, animated: true)
        print("cell pressed")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Disable bounce at top of tableView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            if scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset = CGPoint.zero
            }
        }
        
    }
    
}

// MARK:- YoutubeSpotifyHeaderViewDelegate Methods

extension LibraryViewController: YoutubeSpotifyHeaderViewDelegate {
    func didTapYoutubeButton() {
        // Open Youtube search results
    }
    
    func didTapSpotifyButton() {
        // Open Spotify search results
    }
    
    
}

// MARK:- moreButtonDelegate Methods

extension LibraryViewController: MoreButtonDelegate {
    func didTapMoreButton(cell: SearchTableViewCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("Error: could not retrieve index path")
            return
        }
        let model = LibraryViewController.models[indexPath.row]
        print(model)
        
        // TODO:- Add 'if' statement here so that if the video is already in the library then it says 'Remove from library' (also make this style .destructive so that it is red), otherwise it should say 'Add to library'
        
        actionSheet.addAction(UIAlertAction(
            title: "Remove from library",
            style: .default,
            handler: { action in
                // Display 'are you sure' alert
                let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
                    // Remove from context
                    print(LibraryViewController.models)
                    self.deleteLibraryData(model: model, at: indexPath)
                    print(LibraryViewController.models)
                    
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Copy link",
            style: .default,
            handler: { action in
                // Fetch video url and add to clipboard
                let pasteboard = UIPasteboard.general
                pasteboard.string = model.url
        }))
        
        actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        
        actionSheet.view.tintColor = .label
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    
}

// MARK:- YoutubePlayerViewControllerDelegate

extension LibraryViewController: YoutubePlayerViewControllerDelegate {
    
    func didTapAddToLibraryButton(isInLibrary: Bool, model: YoutubeVideoModel?) {
        print("Tapped add button from library")
        
        if isInLibrary == true {
            // Remove from library
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            let model = LibraryViewController.models[indexPath.row]
            
            deleteLibraryData(model: model, at: indexPath)
        }
        else {
            // Add to library
            let libraryModel = YoutubeLibraryModel(
                entity: YoutubeLibraryModel.entity(),
                insertInto: self.context
            )
            
            guard let model = model else {
                return
            }
            
            libraryModel.thumbnail = model.thumbnail
            libraryModel.title = model.title
            libraryModel.user = model.user
            libraryModel.viewCount = model.viewCount
            libraryModel.id = model.id
            libraryModel.url = model.url
            libraryModel.isInLibrary = model.isInLibrary
            libraryModel.dateAdded = Date()
            
            self.appDelegate.saveContext()
        }
    }
    
}
