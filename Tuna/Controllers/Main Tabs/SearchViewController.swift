//
//  SearchViewController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public var models = [YoutubeVideoModel]()
    
    // MARK:- Create UI
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Search"
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
        
        // TEST: Add testModels to model array
        let testModel = YoutubeVideoModel(
            thumbnail: "https://i.ytimg.com/vi/zMsnnH7Tu34/mqdefault.jpg",
            title: "Galt MacDermot - Coffe Cold",
            user: "xamarufter",
            viewCount: (1234567 as NSNumber).description(withLocale: Locale.current),
            id: "xjhfjhdlskjlsjf",
            url: "www.youtube.com",
            isInLibrary: false
        )
        
        for _ in 0..<10 {
            models.append(testModel)
        }
        
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
            y: headerView.bottom - 3,
            width: view.width,
            height: view.height - headerView.height - (tabBarController?.tabBar.height ?? 10) - (navigationController?.navigationBar.height ?? 10)
        )
        
        dimmedView.frame = view.bounds
    }
    
    // MARK:- Youtube API Integration
    
    private func getData(from urlString: String) {
        
        var videoIds = [String]()
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        print(url)
        
        // 1) Create data task to get video id
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error creating dataTask: \(error!)")
                return
            }
            
            // Have data
            var result: YoutubeModel?
            do {
                result = try JSONDecoder().decode(YoutubeModel.self, from: data)
            }
            catch {
                print("Failed to convert: \(error)")
            }
            
            guard let json = result else {
                return
            }
            
            // Append video id to videoIds array
            for item in json.items {
                guard let id = item.id.idMoreItems?.videoId else {
                    print("Could not retrieve videoIDs")
                    return
                }
                videoIds.append(id)
            }
            
            // 2) Get detailed video data using videoId
            var idsString = ""
            for id in videoIds {
                idsString.append("\(id)%2C")
            }
            let urlString = "https://youtube.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=\(idsString)&key=\(Secrets.youtubeAPIKey)"
            
            print(urlString)
            
            // Get data
            guard let url = URL(string: urlString) else {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    return
                }
                
                // Have data
                var result: YoutubeModel?
                
                do {
                    result = try JSONDecoder().decode(YoutubeModel.self, from: data)
                }
                catch {
                    print("Error decoding data: \(error)")
                }
                
                guard let json = result else {
                    return
                }
                
                // Append each video's details to the models array
                for item in json.items {
                    guard let thumbnailURL = item.snippet?.thumbnails?.medium?.url,
                        let title = item.snippet?.title,
                        let user = item.snippet?.channelTitle,
                        let count = item.statistics?.viewCount,
                        let id = item.id.idString else {
                        return
                    }
                    
                    self.models.append(YoutubeVideoModel(
                        thumbnail: thumbnailURL,
                        title: title,
                        user: user,
                        viewCount: "\((Int(count)! as NSNumber).description(withLocale: Locale.current)) views",
                        id: id,
                        url: "https://www.youtube.com/watch?v=\(id)",
                        isInLibrary: false
                        )
                    )
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            task.resume()
        }
        task.resume()
    }
}


// MARK:- Search bar delegate methods

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        didFinishSearch()
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
        models = [YoutubeVideoModel]()
        
        let queryString = text.replacingOccurrences(of: " ", with: "+")
        
        let baseUrlString = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=25"
        let apiString = "key=\(Secrets.youtubeAPIKey)"
        let urlString = "\(baseUrlString)&q=\(queryString)&\(apiString)"
        
        getData(from: urlString)
    }
    
}

// MARK:- Table View Delegate and Data Source Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
        cell.delegate = self
        guard !models.isEmpty else {
            return UITableViewCell()
        }
        let model = models[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = YoutubePlayerViewController()
        vc.delegate = self
        vc.model = models[indexPath.row]
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
    func didTapMoreButton(cell: SearchTableViewCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("Error: could not retrieve index path")
            return
        }
        let model = models[indexPath.row]
        print(model)
        
        // TODO:- Add 'if' statement here so that if the video is already in the library then it says 'Remove from library' (also make this style .destructive so that it is red), otherwise it should say 'Add to library'
        
        actionSheet.addAction(UIAlertAction(
            title: "Add to library",
            style: .default,
            handler: { action in
                // Add to array of models within library and save to context
                self.addToLibrary(at: indexPath)
                
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
    
    private func addToLibrary(at indexPath: IndexPath) {
        let selectedModel = self.models[indexPath.row]
        
        let libraryModel = YoutubeLibraryModel(
            entity: YoutubeLibraryModel.entity(),
            insertInto: self.context
        )
        
        libraryModel.thumbnail = selectedModel.thumbnail
        libraryModel.title = selectedModel.title
        libraryModel.user = selectedModel.user
        libraryModel.viewCount = selectedModel.viewCount
        libraryModel.id = selectedModel.id
        libraryModel.url = selectedModel.url
        libraryModel.isInLibrary = selectedModel.isInLibrary
        libraryModel.dateAdded = Date()
        self.appDelegate.saveContext()
    }
    
    
}

// MARK:- YoutubePlayerViewControllerDelegate

extension SearchViewController: YoutubePlayerViewControllerDelegate {
    func didTapAddToLibraryButton(isInLibrary: Bool, model: YoutubeVideoModel?) {
        print("Tapped add button from search")
        
        if isInLibrary == true {
            // Remove from library
            let request = YoutubeLibraryModel.createFetchRequest()
            
            guard let id = model?.id else {
                return
            }
            
            request.predicate = NSPredicate(
                format: "%K CONTAINS[c] %@",
                argumentArray: [#keyPath(YoutubeLibraryModel.id), id]
            )
            
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    context.delete(results.last!)
                }
            }
            catch {
                print("Error fetching: \(error)")
            }
            
        }
        else {
            // Add to library
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            self.addToLibrary(at: indexPath)
        }
        
        
        
    }
    
    
}

