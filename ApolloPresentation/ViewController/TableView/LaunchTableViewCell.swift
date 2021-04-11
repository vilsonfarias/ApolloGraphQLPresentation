//
//  LaunchTableViewCell.swift
//  ApolloPresentation
//
//  Created by Jose Vilson de Farias on 4/10/21.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {

    @IBOutlet private weak var launchId: UILabel!
    @IBOutlet private weak var spaceShip: UILabel!

    func update(launchId: String?,
                launchSite: String?,
                spaceShip: String?) {
        self.launchId.text = "Launch \(launchId ?? "") / Site \(launchSite ?? "Unknown")"
        self.spaceShip.text = spaceShip ?? "Unknown"
    }
}
