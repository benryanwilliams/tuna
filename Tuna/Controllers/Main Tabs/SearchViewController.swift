//
//  SearchViewController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit
import Spartan

class SearchViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public var youtubeModels = [YoutubeVideoModel]()
    public var spotifyModels = [SpotifyTrackModel]()
    
    /// State management for header tabs
    private enum HeaderTab {
        case spotifySelected
        case youtubeSelected
    }
    
    private var headerTab: HeaderTab = .youtubeSelected
    
    // MARK:- Create UI
    
    public let searchBar: UISearchBar = {
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
        tableView.register(SpotifyTableViewCell.self, forCellReuseIdentifier: SpotifyTableViewCell.identifier)
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
        
        // MARK:- Test Models
        
        // TEST: Add testModels to model array
        let youtubeTestModel = YoutubeVideoModel(
            thumbnail: "https://i.ytimg.com/vi/zMsnnH7Tu34/mqdefault.jpg",
            title: "Galt MacDermot - Coffe Cold",
            user: "xamarufter",
            viewCount: (1234567 as NSNumber).description(withLocale: Locale.current),
            id: "xjhfjhdlskjlsjf",
            url: "www.youtube.com",
            isInLibrary: false
        )
        
        for _ in 0..<10 {
            youtubeModels.append(youtubeTestModel)
        }
        
        // TEST: Add testModels to model array
        //        let spotifyTestModel = SpotifyTrackModel(
        //            thumbnail: "https://i.scdn.co/image/ab67616d0000b273db1083f417644e3e1cf47543",
        //            artist: "Leon Vynehall",
        //            title: "Nothing Is Still",
        //            trackLength: "8 mins",
        //            id: "6WeIO0CpDMiMXTglv0KuLr",
        //            url: "spotify:album:6WeIO0CpDMiMXTglv0KuLr",
        //            isInLibrary: false
        //        )
        //
        //        for _ in 0..<10 {
        //            spotifyModels.append(spotifyTestModel)
        //        }
        
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
                                    let vc = SearchHistoryViewController()
                                    vc.delegate = self
                                    vc.title = "Search history"
                                    self.navigationController?.pushViewController(vc, animated: true)
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
    
    private func getYoutubeData(from urlString: String) {
        
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
                    
                    self.youtubeModels.append(YoutubeVideoModel(
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
    
    // MARK:- Spotify API Integration
    
    private func getSpotifyData(with text: String) {
        
        // Query based on search
        _ = Spartan.search(query: text, type: .track, success: { (pagingObject: PagingObject<SimplifiedTrack>) in
            
            // Get the tracks via pagingObject.items
            for item in pagingObject.items {
                
                guard let artist = item.artists[0].name,
                      let title = item.name,
                      let id = item.id,
                      let duration = item.durationMs,
                      let uri = item.uri else {
                    return
                }
                
                guard let previewUrl = item.previewUrl else {
                    return
                }
                
                // Get track information
                _ = Spartan.getTrack(id: item.id as! String, market: .gb, success: { (track) in
                    
                    // Get album id of track
                    let albumId = track.id as! String
                    
                    // Get image for track
                    _ = Spartan.getAlbum(id: albumId, market: .gb, success: { (album) in
                        guard let thumbnail = album.images.first?.url else {
                            return
                        }
                        
                        self.spotifyModels.append(SpotifyTrackModel(
                            thumbnail: thumbnail,
                            artist: artist,
                            title: title,
                            trackLength: "\(duration)",
                            id: "\(id)",
                            url: uri,
                            isInLibrary: false,
                            previewUrl: previewUrl
                        ))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }, failure: { (error) in
                        print(error)
                    })
                    
                    
                }, failure: { (error) in
                    print(error)
                })
                
            }
        }, failure: { (error) in
            print(error)
        })

    }
}


// MARK:- Search bar delegate methods

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        didFinishSearch()
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        let searchHistoryModel = SearchHistoryModel(
            entity: SearchHistoryModel.entity(),
            insertInto: context
        )
        searchHistoryModel.text = text
        searchHistoryModel.dateAdded = Date()
        
        self.appDelegate.saveContext()
        
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
        if headerTab == .youtubeSelected {
            
            // Perform YouTube search with text
            youtubeModels = [YoutubeVideoModel]()
            
            let queryString = text.replacingOccurrences(of: " ", with: "+")
            
            let baseUrlString = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=25"
            let apiString = "key=\(Secrets.youtubeAPIKey)"
            let urlString = "\(baseUrlString)&q=\(queryString)&\(apiString)"
            
            getYoutubeData(from: urlString)
        }
        
        else if headerTab == .spotifySelected {
            
            // Perform Spotify search with text
            spotifyModels = [SpotifyTrackModel]()
            
            getSpotifyData(with: text)
            
        }
        
    }
    
}

// MARK:- Table View Delegate and Data Source Methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headerTab == .youtubeSelected {
            return youtubeModels.count
        }
        else {
            return spotifyModels.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if headerTab == .youtubeSelected {
            // Youtube cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as! SearchTableViewCell
            cell.delegate = self
            guard !youtubeModels.isEmpty else {
                return UITableViewCell()
            }
            let model = youtubeModels[indexPath.row]
            cell.configure(with: model)
            return cell
        }
        else {
            // Spotify cell
            let cell = tableView.dequeueReusableCell(withIdentifier: SpotifyTableViewCell.identifier, for: indexPath) as! SpotifyTableViewCell
            cell.delegate = self
            guard !spotifyModels.isEmpty else {
                return UITableViewCell()
            }
            let model = spotifyModels[indexPath.row]
            cell.configure(with: model)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if headerTab == .youtubeSelected {
            let vc = YoutubePlayerViewController()
            vc.delegate = self
            vc.model = youtubeModels[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            print("cell pressed")
        }
        else {
            let vc = SpotifyPlayerViewController()
            vc.delegate = self
            vc.model = spotifyModels[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            print("cell pressed")
        }
        
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
        headerTab = .youtubeSelected
        tableView.reloadData()
        
        print(spotifyModels)
    }
    
    func didTapSpotifyButton() {
        // Open Spotify search results
        headerTab = .spotifySelected
        tableView.reloadData()
        
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
        let model = youtubeModels[indexPath.row]
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
        let selectedModel = self.youtubeModels[indexPath.row]
        
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

// MARK:- SearchHistoryViewControllerDelegate

extension SearchViewController: SearchHistoryViewControllerDelegate {
    func didTapSearchHistoryResult(with text: String) {
        searchBar.text = text
        query(with: text)
    }
    
    
}

// MARK:- SpotifyMoreButtonDelegate

extension SearchViewController: SpotifyMoreButtonDelegate {
    func didTapSpotifyMoreButton(cell: SpotifyTableViewCell) {
        print("Tapped Spotify cell more button")
    }
}

// MARK:- SpotifyPlayerViewControllerDelegate

extension SearchViewController: SpotifyPlayerViewControllerDelegate {
    func didTapSPAddToLibraryButton(isInLibrary: Bool, model: SpotifyTrackModel?) {
        print("Tapped Spotify player more button")
    }
    
    
}

