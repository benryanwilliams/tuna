//
//  SearchHistoryViewController.swift
//  Tuna
//
//  Created by Ben Williams on 06/12/2020.
//  Copyright © 2020 Ben Williams. All rights reserved.
//

import UIKit

protocol SearchHistoryViewControllerDelegate: AnyObject {
    func didTapSearchHistoryResult(with text: String)
}

class SearchHistoryViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static var models = [SearchHistoryModel]()
    
    weak var delegate: SearchHistoryViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .label
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let request = SearchHistoryModel.createFetchRequest()
        
        let sortByDate = NSSortDescriptor(key: "dateAdded", ascending: false)
        request.sortDescriptors = [sortByDate]
        
        do {
            SearchHistoryViewController.models = try context.fetch(request)
        }
        catch {
            print("Error fetching: \(error)")
        }
        tableView.reloadData()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    
}

extension SearchHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SearchHistoryViewController.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = SearchHistoryViewController.models[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let text = SearchHistoryViewController.models[indexPath.row].text else {
            return
        }
        
        delegate?.didTapSearchHistoryResult(with: text)
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    
}
