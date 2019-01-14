//
//  NotificationsViewController.swift
//  MeetSivi
//
//  Created by Norayr Harutyunyan on 1/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifications"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = "Notification title"
            cell.detailTextLabel?.text = "Notification sub title"

            return cell
        }
        
        return UITableViewCell()
    }
}
