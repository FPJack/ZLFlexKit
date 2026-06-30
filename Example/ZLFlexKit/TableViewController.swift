//
//  TableViewController.swift
//  ZLFlexKit_Example
//
//  Created by admin on 2026/6/30.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import ZLFlexKit
class TableCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let label = UILabel()
        label.numberOfLines = 0
        label.text = """
        111111111111111111111111111111111111111111111111111111111111111
        222222222222222222222222222222222222222222222222222222222222222
        333333333333333333333333333333333333333333333333333333333333333
        """

        VStackView {
            UISwitch()
            UISwitch()
            UISwitch()
            UISwitch()
            UISwitch()
            label
        }.insets(.all(50)).box.addToFull(self.contentView)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.box.addToFull(self.contentView)
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(TableCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 10
    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        

        return cell
    }


    
}
