//
//  ViewController.swift
//  ApolloPresentation
//
//  Created by Jose Vilson de Farias on 4/9/21.
//

import UIKit
import Apollo

class LaunchViewController: UIViewController {

    @IBOutlet weak var launchesTableView: UITableView!

    private var launches = [LaunchListQuery.Data.Launch.Launch]()
    private var lastConnection: LaunchListQuery.Data.Launch?
    private var activeRequest: Cancellable?

    enum ListSection: Int, CaseIterable {
      case launches
      case loading
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        launchesTableView.dataSource = self
        launchesTableView.delegate = self
        loadMoreLaunchesIfTheyExist()
    }

    func showErrorAlert(title: String, message: String) {
        print("\(title) | \(message)")
    }
}

//MARK:- GraphQL

private extension LaunchViewController {
    func loadMoreLaunches(from cursor: String?) {
        activeRequest = Network.shared.apollo.fetch(query: LaunchListQuery(cursor: cursor)) { [weak self] result in
            guard let self = self else { return }
            self.activeRequest = nil
            defer { self.launchesTableView.reloadData() }

            switch result {
            case .success(let graphQLResult):
                if let launchConnection = graphQLResult.data?.launches {
                    self.lastConnection = launchConnection
                    self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
                }

                if let errors = graphQLResult.errors {
                    let message = errors
                        .map { $0.localizedDescription }
                        .joined(separator: "\n")

                    self.showErrorAlert(title: "GraphQL Error(s)", message: message)
                }
            case .failure(let error):
                self.showErrorAlert(title: "Network Error", message: error.localizedDescription)
            }
        }
    }

    func loadMoreLaunchesIfTheyExist() {
      guard let connection = self.lastConnection else {
        // We don't have stored launch details, load from scratch
        self.loadMoreLaunches(from: nil)
        return
      }

      guard connection.hasMore else {
        // No more launches to fetch
        return
      }

      self.loadMoreLaunches(from: connection.cursor)
    }

    func handleResponse(data: LaunchListQuery.Data?, errors: [GraphQLError]?) {
        if let launchConnection = data?.launches {
          self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
        }

        if let errors = errors {
          let message = errors
                .map { $0.localizedDescription }
                .joined(separator: "\n")
          self.showErrorAlert(title: "GraphQL Error(s)",
                              message: message)
        }
    }
}

//MARK:- TableView Delegate

extension LaunchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 &&
            indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            loadMoreLaunchesIfTheyExist()
        }
    }
}

//MARK:- TableView Data Source

extension LaunchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection: \(launches.count)")
        guard let listSection = ListSection(rawValue: section) else {
          assertionFailure("Invalid section")
          return 0
        }

        switch listSection {
        case .launches:
            return self.launches.count
        case .loading:
            if self.lastConnection?.hasMore == false {
                return 0
            } else {
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "LaunchTableViewCellID", for: indexPath) as? LaunchTableViewCell
        else {
            return UITableViewCell()
        }

        guard let listSection = ListSection(rawValue: indexPath.section) else {
            assertionFailure("Invalid section")
            return cell
        }

        switch listSection {
        case .loading:
            if self.activeRequest == nil {
                cell.textLabel?.text = "Tap to load more"
            } else {
                cell.update(launchId: "Loading",
                            launchSite: "Loading",
                            spaceShip: "Loading")
            }
        case .launches:
            let launch = self.launches[indexPath.row]
            cell.update(launchId: launch.id,
                        launchSite: launch.site,
                        spaceShip: launch.rocket?.name)
        }

        return cell
    }
}
