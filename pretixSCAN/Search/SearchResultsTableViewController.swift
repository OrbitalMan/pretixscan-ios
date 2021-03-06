//
//  SearchOrderPositionsTableViewController.swift
//  PretixScan
//
//  Created by Daniel Jilg on 19.03.19.
//  Copyright © 2019 rami.io. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    private static let reuseIdentifier = "SearchOrderPositionsTableViewControllerCell"
    var appCoordinator: AppCoordinator?

    // MARK: - Private Properties
    @IBOutlet private var searchHeaderView: SearchHeaderView!
    private var numberOfSearches = 0
    private var results = [OrderPosition]()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.SearchOrderPositionsTableViewController.Title
        tableView.tableHeaderView = searchHeaderView
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewController.reuseIdentifier, for: indexPath)
        guard let cell = defaultCell as? SearchResultTableViewCell else { return defaultCell }

        let result = results[indexPath.row]
        cell.orderPosition = result
        cell.event = appCoordinator?.getConfigStore().event
        cell.checkInList = appCoordinator?.getConfigStore().checkInList
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = results[indexPath.row]
        dismiss(animated: true, completion: nil)
        appCoordinator?.redeem(secret: result.secret, force: false, ignoreUnpaid: false)
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText.count > 2 else {
            searchHeaderView.status = .notEnoughCharacters
            results = []
            tableView.reloadData()
            return
        }

        let nextSearchNumber = numberOfSearches + 1

        searchHeaderView.status = .loading
        deferredSearch(query: searchText) { (orders, error) in
            DispatchQueue.main.async {
                // Protect against old slow searches overwriting new fast searches
                guard nextSearchNumber > self.numberOfSearches else { return }

                // Update Results
                self.presentErrorAlert(ifError: error)
                self.results = orders ?? []
                self.tableView.reloadData()
                self.searchHeaderView.status = .searchCompleted(results: self.results.count)
            }
        }
    }

    func deferredSearch(query: String, completionHandler: @escaping ([OrderPosition]?, Error?) -> Void) {
        appCoordinator?.getConfigStore().ticketValidator?.search(query: query, completionHandler: completionHandler)
    }
}
