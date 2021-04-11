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

    private var lastCursor: LaunchListQuery.Data.Launch?

    var launches = [LaunchListQuery.Data.Launch.Launch]()

    override func viewDidLoad() {
        super.viewDidLoad()
        launchesTableView.dataSource = self
        loadLaunches()
    }

    func showErrorAlert(title: String, message: String) {
        print("\(title) | \(message)")
    }
}

//MARK:- GraphQL

extension LaunchViewController {
    private func loadLaunches() {
        Network.shared.apollo
            .fetch(query: LaunchListQuery()) { [weak self] result in
                guard let self = self else { return }
                defer { self.launchesTableView.reloadData() }

                switch result {
                case .success(let graphQLResult):
                    self.handleResponse(data: graphQLResult.data,
                                        errors: graphQLResult.errors)
                case .failure(let error):
                    self.showErrorAlert(title: "Network Error",
                                        message: error.localizedDescription)
                }
            }
    }

    private func handleResponse(data: LaunchListQuery.Data?, errors: [GraphQLError]?) {
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

//MARK:- TableView Data Source

extension LaunchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection: \(launches.count)")
        return launches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "LaunchTableViewCellID", for: indexPath) as? LaunchTableViewCell
        else {
            return UITableViewCell()
        }

        let launch = self.launches[indexPath.row]
        cell.update(launchId: launch.id,
                    launchSite: launch.site)

        return cell
    }
}
