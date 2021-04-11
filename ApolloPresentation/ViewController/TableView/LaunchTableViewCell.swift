//
//  LaunchTableViewCell.swift
//  ApolloPresentation
//
//  Created by Jose Vilson de Farias on 4/10/21.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {

    @IBOutlet private weak var launchId: UILabel!

    func update(launchId: String?,
                launchSite: String?) {
        self.launchId.text = "Launch \(launchId ?? "") / Site \(launchSite ?? "Unknown")"
    }
}
